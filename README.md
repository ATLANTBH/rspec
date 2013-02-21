rspec dbformatter
=================

Database Formatter enables writing RSpec test results into a database

requirements: database, activerecord-adapter gem for the database, yaml gem, active_record gem

usage (see .rspec):
rspec --require ./lib/dbformatter.rb --format DBFormatter

config / createdb.rb will create necessary tables in the database

config / config.yml contains options (suite, build, backtrace ON/OFF) and database connection
