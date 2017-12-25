require 'yaml'
require "active_record"

class AddTestCaseScreenshots < ActiveRecord::Migration[5.0]
  def self.up
    add_column :test_cases, :screenshot_path, :string
    add_column :test_cases, :screenshot_url, :string
  end
end
