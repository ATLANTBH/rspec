require 'rspec/core/formatters/base_text_formatter'
require 'active_record'
require 'yaml'
require './lib/rspec2db/utils/db_utils'
require './lib/rspec2db/utils/rspec_configuration_helper'

class Rspec2db < RSpec::Core::Formatters::BaseTextFormatter
  include DBUtils
  include RSpecConfigurationHelper

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

  attr_reader :output,
              :results,
              :config,
              :example_group,
              :global_file_lock,
              :test_run,
              :test_suite


  def initialize(output)
    @output = output || StringIO.new
    @global_file_lock = '/tmp/rspec2db.lock'
    @config = RSpecConfigurationHelper.load_config
    connect_to_db @config
    @test_suite = create_test_suite(config)
    @test_run = create_test_run(@test_suite)
  end

  def start(notification)
  end

  def example_group_started(notification)
    @example_group = notification.group
  end

  def example_group_finished(notification)
  end

  def example_started(example)
  end

  def example_passed(notification)
    @current_test_case = create_test_case(@test_run, @example_group, notification.example, @config['options']['backtrace'])
  end

  def example_pending(notification)
    @current_test_case = create_test_case(@test_run, @example_group, notification.example, @config['options']['backtrace'])
  end

  def example_failed(notification)
    @current_test_case = create_test_case(@test_run, @example_group, notification.example, @config['options']['backtrace'])
  end

  def message(notification)
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
    update_test_run(@test_run, notification, @global_file_lock)
  end

  def seed(seed)
  end

end
