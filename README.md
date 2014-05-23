rspec2db: RSpec DB Formatter
============================

Database Formatter enables writing RSpec test results into a database

- install the database (for example: postgres)
- git clone this repository
- gem build rspec2db.gemspec (to build the rspec2db gem)
- bundle install (to make sure you have the required gems)
- gem install rspec2db-#{VERSION}.gem to install rspec2db gem
- check rspec2db.yml configuration (db connection)
- create database if it does not already exist (it must match with database property specified in rspec2db.yml)
- execute rspec_db.rb to create tables and relations in the database
- copy the rspec2db.yml to your projec
- check that .rspec file contains following: 
  --require rspec2db
  --format Rspec2db
  --options with location to rspec2db.yml relative to .rspec file (for example: --options ./config/rspec2db.yml)

Run RSpec tests using the rspec command (from the location where .rspec file exist, to be able to pick up parameters defined in .rspec)
