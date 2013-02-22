rspec dbformatter
=================

Database Formatter enables writing RSpec test results into a database

- install the database
- copy the files to your project
- gem build dbformatter.gemspec (to build the dbformatter gem)
- bundle install (to make sure you have the required gems, including dbformatter)
- check config.yml configuration (db connection)
- execute creadedb.rb to create tables and relations in the db
- check that .rspec file calls the formatter --require dbformatter --format DBFormatter
