require 'rubygems'
require 'yaml'
require 'active_record'

module DBUtils
  def self.create_rspec_db(dbconfig)
    ActiveRecord::Base.establish_connection(dbconfig)

    ActiveRecord::Schema.define(version: 1) do
      create_table :test_suites, force: :cascade do |t|
        t.string :suite
        t.timestamps
      end

      create_table :test_runs, force: :cascade do |t|
        t.float :duration
        t.integer :example_count
        t.integer :failure_count
        t.integer :pending_count
        t.string :build
        t.string :computer_name
        t.string :git_hash
        t.string :git_branch
        t.timestamps
        t.references :test_suites
      end

      create_table :test_cases, force: :cascade do |t|
        t.string :test_group
        t.string :context
        t.string :description
        t.string :execution_result
        t.text :exception
        t.string :pending_message
        t.float :duration
        t.text :backtrace
        t.text :metadata
        t.timestamps
        t.references :test_runs
      end
    end
  end

  def self.migrate_rspec_db(dbconfig)
    ActiveRecord::Base.establish_connection(dbconfig)
    ActiveRecord::Migrator.migrate './lib/rspec2db/db/migrations'
  end
end
