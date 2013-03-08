rspec2db: RSpec DB Formatter
============================

Database Formatter enables writing RSpec test results into a database

- install the database
- copy the files to your project
- gem build rspec2db.gemspec (to build the rspec2db gem)
- bundle install (to make sure you have the required gems)
- gem install rspec2db-#{VERSION}.gem to install rspec2db gem
- check rspec2db.yml configuration (db connection)
- execute rspec_db.rb to create tables and relations in the db
- check that .rspec file calls the formatter --require rspec2db --format Rspec2db and contains --options with location to rspec2db.yml defined

Run RSpec tests using the rspec command (from the location where .rspec file exist, to be able to pick up parameters defined in .rspec)
