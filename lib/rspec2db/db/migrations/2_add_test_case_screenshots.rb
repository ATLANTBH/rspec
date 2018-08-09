require 'yaml'
require "active_record"

class AddTestCaseScreenshots < ActiveRecord::Migration[5.2]
  def self.up
    add_column :test_cases, :screenshot_path, :string
    add_column :test_cases, :screenshot_url, :string
    add_column :test_runs, :environment, :string
  end
end