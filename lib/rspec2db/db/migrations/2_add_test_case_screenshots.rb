require 'yaml'
require "active_record"

class AddTestCaseScreenshots < ActiveRecord::Migration[5.2]
  def self.up
    add_column :test_cases, :screenshot_path, :string
    add_column :test_cases, :screenshot_url, :string
    add_column :test_runs, :environment, :string
    add_column :test_cases, :bug_title, :string
    add_column :test_cases, :bug_url, :string
    add_column :test_cases, :notes, string
  end
end
