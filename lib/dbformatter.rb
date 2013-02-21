require 'rspec/core/formatters/base_text_formatter'
require 'active_record'
require 'yaml'
require 'test_case'
require 'test_run'
require 'test_suite'

=begin 
 
  see http://rdoc.info/github/rspec/rspec-core/RSpec/Core/Formatters/BaseFormatter
  The reporter calls every formatter with this protocol:
  
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


class DBFormatter < RSpec::Core::Formatters::BaseTextFormatter
  
    attr_reader :output, :results, :example_group

    def initialize(output)
      @output = output || StringIO.new
      @results = {} 
      
      @config = YAML::load(File.open('./config/config.yml'))
      
      ActiveRecord::Base.establish_connection(@config["dbconnection"])
      @testrun = TestRun.create()
      @testsuite = TestSuite.find_or_create_by_suite(:suite=>@config["options"]["suite"])
    end
    
    
    def insert_test_case(example)
      @testcase = TestCase.create(
        :testrun_id=>@testrun.id,
        :test_group=>@example_group.top_level_description,
        :description=>example.description,
        :execution_result=>example.execution_result[:status],
        :duration=>example.execution_result[:run_time],
        :pending_message=>example.execution_result[:pending_message].to_s,
        :exception=>example.execution_result[:exception].to_s
        )
    
      if @config["options"]["backtrace"] == "ON" 
        @testcase.update_attributes(
          :backtrace=>example.execution_result[:backtrace], #fix 
          :metadata=>example.metadata
        )
      end
      
      if !example_group.top_level? #@example_group.top_level_description != @example_group.display_name
        @testcase.update_attributes(
          :context=>@example_group.display_name
        )
      end
        
    end  
    
    def insert_test_run(duration, example_count, failure_count, pending_count)
       @testrun.update_attributes(
        :testsuite_id=>@testsuite.id,
        :duration=>duration, 
        :example_count=>example_count, 
        :failure_count=>failure_count, 
        :pending_count=>pending_count,
        :build=>@config["options"]["build"]) 
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
      insert_test_run(duration, example_count, failure_count, pending_count)
    end

    # no-op
    def seed(seed)
    end

    def close()
    end
 


end