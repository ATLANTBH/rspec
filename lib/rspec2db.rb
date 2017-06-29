require 'rspec/core/formatters/base_text_formatter'
require 'active_record'
require 'yaml'

class TestCase < ActiveRecord::Base
  # "testcase" is the core concept and corresponds to RSpec Example (it...do...end)
  # this part logs example details (Describe, Context, it), execution result and other details (exception, pending message etc.)
  belongs_to :testrun
end

class TestRun < ActiveRecord::Base
  # "testrun" records time of the test execution, duration, pass rate
  # and contains build number as specified in the yml configuration file
  has_many :testcases
  belongs_to :testsuite
end

class TestSuite < ActiveRecord::Base
  # depending on your needs, you may have more "testsuites" (e.g. Regression, Full, Quick, Smoke etc)
  # or multiple projects that share the same database for RSpec test results
  has_many :testruns
end


class Rspec2db < RSpec::Core::Formatters::BaseTextFormatter

    RSpec::Core::Formatters.register self, :start,
                                           :example_group_started,
                                           :example_started,
                                           :example_passed,
                                           :example_pending,
                                           :example_failed,
                                           :dump_failures,
                                           :dump_pending,
                                           :dump_summary,
                                           :dump_profile

    attr_reader :output, :results, :example_group, :global_file_lock

    def initialize(output)
      @output = output || StringIO.new
      @results = {}
      @rspec_core_version = extract_rspec_core_version
      @global_file_lock = '/tmp/rspec2db.lock'
      load_config
      establish_db_connection
    end

    def insert_test_case(notification)
      example = notification.example
      @testcase = TestCase.create(
        :test_runs_id=>@testrun.id,
        :test_group=>@example_group.top_level_description,
        :description=>example.description,
        :execution_result=>example.execution_result.status,
        :duration=>example.execution_result.run_time,
        :pending_message=>example.execution_result.pending_message.to_s,
        :exception=>example.execution_result.exception.to_s)
      if @config["options"]["backtrace"] && !example.execution_result.exception.nil?  && !example.execution_result.exception.backtrace.nil?
         File.open('/tmp/output', 'w'){ |w| w.write(example.execution_result.exception.backtrace) }
         @testcase.update_attributes(
         :backtrace=> example.execution_result.exception.backtrace.join('\n'),
         :metadata=>print_example_failed_content(example)
         )
      end
      if !example_group.top_level? # check for detecting Context (as opposed to Describe group)
        @testcase.update_attributes(
          :context=>@example_group.description)
      end
    end

    def print_example_failed_content(example)
      print_content = ''
      exception = example.execution_result.exception
      return print_content if exception.backtrace.nil?

      backtrace_content = exception.backtrace.map { |line| RSpec::Core::BacktraceFormatter.new.backtrace_line(line) }
      backtrace_content.compact!
      @snippet_extractor ||= create_snippet_extractor

      snippet_content = @snippet_extractor.snippet(backtrace_content)
      snippet_content = snippet_content.sub( "class=\"offending\"", "class=\"offending\" style=\"background-color: red;\"" )
      print_content = "    <pre class=\"ruby\" style=\"background-color: #E6E6E6; border: 1px solid;\"><code>#{snippet_content}</code></pre>"
      return print_content
    end

    def start(notification)
    end

    def example_group_started(notification)
      @example_group=notification.group
    end

    def example_group_finished(notification)
    end

    def example_started(example)
    end

    def example_passed(notification)
      insert_test_case(notification)
    end

    def example_pending(notification)
      insert_test_case(notification)
    end

    def example_failed(notification)
      insert_test_case(notification)
    end

    def message(notification)
      @message=notification.message
    end

    def start_dump(notification)
    end

    def dump_pending(notification)
    end

    def dump_profile(notification)
    end

    def dump_failures(notification)
    end

    def dump_summary(notification)
      @global_lock = File.new(@global_file_lock, File::CREAT | File::TRUNC)
      begin
        @global_lock.flock(File::LOCK_EX)
        #@testrun.increment(:example_count, notification.example_count)
        #       .increment(:failure_count, notification.failure_count)
        #       .increment(:pending_count, notification.pending_count)
        #       .increment(:duration, notification.duration)
        #       .save!
        @testrun.update_attributes(
          :duration=>notification.duration,
          :example_count=>notification.example_count,
          :failure_count=>notification.failure_count,
          :pending_count=>notification.pending_count)
        @global_lock.flock(File::LOCK_UN)
      rescue Exception => e
        puts e.message
        puts e.backtrace
      ensure
        @global_lock.flock(File::LOCK_UN)
      end
    end

    def seed(seed)
    end
private
    def extract_rspec_core_version
      Gem.loaded_specs['rspec-core'].version.to_s.split('.').map { |v| v.to_i }
    end

    def create_snippet_extractor
      major_version = @rspec_core_version[0]
      minor_version = @rspec_core_version[1]

      rspec_3_requirement = major_version == 3 && minor_version >= 0 && minor_version <= 3
      rspec_3_4_requirement = major_version == 3 && minor_version >= 4 

      if rspec_3_requirement
        require 'rspec/core/formatters/snippet_extractor'
        RSpec::Core::Formatters::SnippetExtractor.new
      elsif rspec_3_4_requirement
        require 'rspec/core/formatters/html_snippet_extractor'
        RSpec::Core::Formatters::HtmlSnippetExtractor.new
      end
    end

    def load_config
      # open the yml configuration file to read db connection and other properties
      rspec_file = '.rspec'
      file_path = nil
      File.open(rspec_file).each do |line|
       if (line.match('--options\s?.+yml')) # filter lines that contain path to yml file
           line.slice!('--options ')
           file_path = line.strip
       end
      end
      if File.exists?(file_path)
        # puts "opening the config file"
        @config = YAML::load(File.open(file_path))
        # @config = YAML::load(File.open('./config/rspec2db.yml'))
      else
        puts "could not find the config file at the following location"
        puts file_path
        abort("exiting... please check your config file")
      end
    end

    def establish_db_connection
      ActiveRecord::Base.establish_connection(@config["dbconnection"])

      # Find or create test suite
      @testsuite = TestSuite.find_or_create_by_suite(:suite=>@config["options"]["suite"])

      test_run_hash = {
        :build=>@config["options"]["build"],
        :test_suites_id=>@testsuite.id,
        :git_hash=>ENV["GIT_COMMIT"],
        :git_branch=>ENV["GIT_BRANCH"]
      }

      # Find or create test run
      @global_lock = File.new(@global_file_lock, File::CREAT | File::TRUNC)

      begin
        @global_lock.flock(File::LOCK_EX)
        @testrun = TestRun.where(test_run_hash).first || TestRun.create(test_run_hash)
        @global_lock.flock(File::LOCK_UN)
      rescue Exception => e
        puts e.message
        puts e.backtrace
      ensure
        @global_lock.flock(File::LOCK_UN)
      end
    end
end
