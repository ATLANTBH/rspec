require 'active_record'
require_relative 'rspec_configuration_helper'
require_relative '../db/schema.rb'
require_relative '../db/build_execution_stats'
require_relative '../models/test_case'
require_relative '../models/test_run'
require_relative '../models/test_suite'

module DBUtils
  include RSpecConfigurationHelper

  def connect_to_db(config)
    ActiveRecord::Base.establish_connection(config['dbconnection'])
    ActiveRecord::Base.default_timezone = :local
  end

  def create_test_suite(config)
    test_suite = TestSuite.find_or_create_by(suite: config['options']['suite'])
  end

  def create_test_run(test_suite, config, global_file_lock = '/tmp/.rspec2db.yaml')
    test_run_hash = {
      build: config['options']['build'],
      test_suites_id: test_suite.id,
      git_hash: config['options']['git_commit'],
      git_branch: config['options']['git_branch']
    }
    global_lock = File.new(global_file_lock, File::CREAT | File::TRUNC)

    begin
      global_lock.flock(File::LOCK_EX)
      test_run = TestRun.where(test_run_hash).first || TestRun.create(test_run_hash)
      global_lock.flock(File::LOCK_UN)
    rescue Exception => e
      puts e.message
      puts e.backtrace
    ensure
      global_lock.flock(File::LOCK_UN)
    end
    test_run
  end

  def create_test_case(test_run, example_group, example, backtrace = nil, screenshot_event = nil)
    example
    test_case = TestCase.create(
      test_runs_id: test_run.id,
      test_group: example_group.top_level_description,
      description: example.description,
      execution_result: example.execution_result.status,
      duration: example.execution_result.run_time,
      pending_message: example.execution_result.pending_message.to_s,
      exception: example.execution_result.exception.to_s)

    if backtrace && !example.execution_result.exception.nil?  && !example.execution_result.exception.backtrace.nil?
       File.open('/tmp/output', 'w'){ |w| w.write(example.execution_result.exception.backtrace) }
       test_case.update_attributes(
         backtrace: example.execution_result.exception.backtrace.join('\n'),
         metadata: print_example_failed_content(example)
       )
    end

    if !example_group.top_level? # check for detecting Context (as opposed to Describe group)
      test_case.update_attributes(
        context: example_group.description
      )
    end
    if screenshot_event[:example] && screenshot_event[:example] == example.description
      screenshot_event.delete :example
      test_case.update_attributes screenshot_event
      screenshot_event = {}
    end
    test_case
  end

  def update_test_run(test_run, summary, global_file_lock = nil)
    global_lock = File.new(global_file_lock, File::CREAT | File::TRUNC)
    begin
      global_lock.flock(File::LOCK_EX)
      test_run.reload
      test_run.increment(:example_count, summary.example_count)
             .increment(:failure_count, summary.failure_count)
             .increment(:pending_count, summary.pending_count)
             .increment(:duration, summary.duration)
             .save!
      global_lock.flock(File::LOCK_UN)
    rescue Exception => e
      puts e.message
      puts e.backtrace
    ensure
      global_lock.flock(File::LOCK_UN)
    end
  end
end
