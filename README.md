rspec2db: RSpec DB Formatter
============================

Database Formatter enables writing RSpec test results into a database

- Install postgres database 
(e.g. http://postgresapp.com/). Run "psql" command to see if postgres is properly installed. If you face difficulty running psql, try to set up path to psql (e.g. PATH="/Applications/Postgres.app/Contents/Versions/9.3/bin:$PATH")  

- git clone this (rspec) repository. Ssh key should be generated in order to clone repository: https://help.github.com/articles/generating-ssh-keys. xcode (developers tools) should be installed in order to run git command

- gem build rspec2db.gemspec from "rspec" directory (to build the rspec2db gem) 

- bundle install (to make sure you have the required gems)
You first need to install the bundler gem: gem install bundler. If you don't have write permissions for the "Gems" directory, add "sudo" command in front of "gem install" (e.g. sudo gem install pg)

- if bundle failed on pg gem instalation, try to use one of the following commands: 
  (e.g. ---gem install pg -- --with-pg-config=/Applications/Postgres.app/Contents/Versions/9.3/bin/pg_config)
  (e.g.sudo ARCHFLAGS="-arch x86_64" gem install pg)
  (e.g. apt-get install libpq-dev]) - Ubuntu

- gem install rspec2db-#{VERSION}.gem to install rspec2db gem (e.g. gem install rspec2db-0.1.3.gem)

- check rspec2db.yml (/rspec/config) configuration (db connection)

- create database if it does not already exist (it must match with database property specified in rspec2db.yml)

- execute rspec_db.rb (/rspec/config) to create tables and relations in the database (e.g.ruby rspec_db.rb)

- install rspec gem (e.g. sudo gem install rspec -v 2.13.0)

- initialize your project RSpec (e.g. rspec --init)

- check that .rspec file contains following: --require rspec2db --format Rspec2db --options with location to rspec2db.yml relative to .rspec file (e.g. --options ./config/rspec2db.yml)

- run RSpec tests using the rspec command (from the location where .rspec file exist, to be able to pick up parameters defined in .rspec) (e.g. rspec spec/spec_spec.rb)
