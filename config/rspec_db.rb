require 'yaml'
require 'active_record'

dbconfig = YAML::load(File.open('./rspec2db.yml'))
ActiveRecord::Base.establish_connection(dbconfig["dbconnection"])

ActiveRecord::Base.transaction do

  ActiveRecord::Migration.create_table :test_suites do |t|
    t.string :suite
    t.timestamps
  end  
    
  ActiveRecord::Migration.create_table :test_runs do |t|
    t.references :testsuite 
    t.float :duration
    t.integer :example_count
    t.integer :failure_count
    t.integer :pending_count
    t.string :build
    t.string :computer_name
    t.timestamps
  end
  
  ActiveRecord::Migration.create_table :test_cases do |t|
    t.references :testrun
    t.string :test_group
    t.string :context
    t.string :description
    t.string :execution_result
    t.string :exception
    t.string :pending_message
    t.float :duration
    t.text :backtrace
    t.text :metadata
    t.timestamps
  end

end