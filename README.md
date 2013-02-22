rspec dbformatter
=================

Database Formatter enables writing RSpec test results into a database

- install the database
- copy the files to your project
- bundle install to make sure you have the required gems
- check config.yml configuration (db connection)
- execute creadedb.rb to create tables and relations in the db
- check that .rspec file calls the formatter --require ./lib/dbformatter.rb --format DBFormatter
