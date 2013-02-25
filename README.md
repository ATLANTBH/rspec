rspec2db: rspec dbformatter
===========================

Database Formatter enables writing RSpec test results into a database

- install the database
- copy the files to your project
- gem build rspec2db.gemspec (to build the dbformatter gem)
- bundle install (to make sure you have the required gems, including dbformatter)
- check rspec2db.yml configuration (db connection)
- execute rspec_db.rb to create tables and relations in the db
- check that .rspec file calls the formatter --require rspec2db --format Rspec2db and contains --options with location to rspec2db.yml defined

Run rspec tests from the location where .rspec file exist, to be able to pick up parameters defined in .rspec
