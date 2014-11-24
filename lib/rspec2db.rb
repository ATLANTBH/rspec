require 'rspec/core/formatters/base_text_formatter'
require 'rspec/core/formatters/snippet_extractor'
require 'active_record'
require 'yaml'
#require 'logger' # require only if you turn on database logging for debugging, e.g. ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'w'))

=begin 
  rspec2db formatter lets you write RSpec test results and all details produced by formatters to a database
  it has been tested with PostgreSQL but it should work with any database supported by ActiveRecord 
  (just check that you have corresponding ActiveRecord-databse adapter gem installed)
  
  the RSpec reporter calls any formatter with the following protocol
  (see http://rdoc.info/github/rspec/rspec-core/RSpec/Core/Formatters/BaseFormatter)
    start(expected_example_count)
    zero or more of the following
      example_group_started(group)
      example_started(example)
      example_passed(example)
      example_failed(example)
      example_pending(example)
      message(string)
    stop
    start_dump
    dump_pending
    dump_failures
    dump_summary(duration, example_count, failure_count, pending_count)
    seed(value)
    close
=end

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
  
    attr_reader :output, :results, :example_group

    def initialize(output)
      @output = output || StringIO.new
      @results = {} 
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
      
      # ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'w'))
      ActiveRecord::Base.establish_connection(@config["dbconnection"])
      @testrun = TestRun.create()
      @testrun.update_attributes(
        :test_suites_id=>nil,
        :duration=>nil, 
        :example_count=>nil, 
        :failure_count=>nil, 
        :pending_count=>nil,
        :build=>@config["options"]["build"],
        :computer_name=>ENV["COMPUTERNAME"])
      @testsuite = TestSuite.find_or_create_by_suite(:suite=>@config["options"]["suite"]) 

    end    
    
    def insert_test_case(example)
      @testcase = TestCase.create(
        :test_runs_id=>@testrun.id,
        :test_group=>@example_group.top_level_description,
        :description=>example.description,
        :execution_result=>example.execution_result[:status],
        :duration=>example.execution_result[:run_time],
        :pending_message=>example.execution_result[:pending_message].to_s,
        :exception=>example.execution_result[:exception].to_s)
      if @config["options"]["backtrace"] && !example.execution_result[:exception].nil? # write additional details if backtrace is configured to true         
         @testcase.update_attributes(    
         :backtrace=>format_backtrace(example.execution_result[:exception].backtrace, example).join("\n"),
         :metadata=>print_example_failed_content(example)
         )
      end
      if !example_group.top_level? # check for detecting Context (as opposed to Describe group)
        @testcase.update_attributes(
          :context=>@example_group.description)
      end
    end

    def print_example_failed_content(example)
      exception = example.metadata[:execution_result][:exception]
      backtrace_content = exception.backtrace.map { |line| backtrace_line(line) }
      backtrace_content.compact!

      @snippet_extractor ||= RSpec::Core::Formatters::SnippetExtractor.new
      snippet_content = @snippet_extractor.snippet(backtrace_content)
      snippet_content = snippet_content.sub( "class=\"offending\"", "class=\"offending\" style=\"background-color: red;\"" )
      print_content = "    <pre class=\"ruby\" style=\"background-color: #E6E6E6; border: 1px solid;\"><code>#{snippet_content}</code></pre>"
      return print_content
    end    

    def start(example_count)
    end

    def example_group_started(example_group)
      @example_group=example_group
    end

    def example_group_finished(example_group)
    end

    def example_started(example) 
    end

    def example_passed(example)
      insert_test_case(example)
    end

    def example_pending(example)
      insert_test_case(example)
    end

    def example_failed(example)
      insert_test_case(example)
    end

    def message(message)
      @message=message
    end

    def stop
    end

    def start_dump()
    end

    def dump_pending()
    end

    def dump_failures()
    end

    def dump_summary(duration, example_count, failure_count, pending_count)
       @testrun.update_attributes(
        :test_suites_id=>@testsuite.id,
        :duration=>duration, 
        :example_count=>example_count, 
        :failure_count=>failure_count, 
        :pending_count=>pending_count,
        :build=>@config["options"]["build"],
        :computer_name=>ENV["COMPUTERNAME"])       
    end

    def seed(seed)
    end

    def close()
    end

end
