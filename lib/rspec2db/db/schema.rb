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
        t.string :environment
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
        t.string :screenshot_path
        t.string :screenshot_url
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
    migrations_path = Bundler.rubygems.find_name('rspec2db').first.full_gem_path + '/lib/rspec2db/db/migrations'
    migration_context = ActiveRecord::MigrationContext.new(migrations_path)
    migration_context.migrate
  end
end
