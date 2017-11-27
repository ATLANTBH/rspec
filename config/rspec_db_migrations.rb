require 'rubygems'
require 'yaml'
require 'active_record'

dbconfig = YAML::load(File.open('./rspec2db.yml'))
ActiveRecord::Base.establish_connection(dbconfig["dbconnection"])

ActiveRecord::Base.transaction do  
  ActiveRecord::Migration.change_table :test_cases do |t|
    t.string :screenshot_path
    t.string :screenshot_url
  end
end
