rspec2db: RSpec DB Formatter
============================

Database Formatter enables writing RSpec test results into database.

Installation steps:

- Install postgres database 

- git clone this (rspec) repository

- gem build rspec2db.gemspec from "rspec" directory (to build the rspec2db gem)

- bundle install (to make sure you have the required gems)

- if bundle failed on pg gem instalation, try to use one of the following commands:
```
Mac OS X - gem install pg -v '0.14.1' -- --with-pg-config=#{PG_CONFIG_PATH} (e.g. /Applications/Postgres.app/Contents/Versions/9.3/bin/pg_config)
Note: If this does not work, try with: ARCHFLAGS="-arch x86_64" gem install pg -v '0.14.1'
Ubuntu - apt-get install libpq-dev before running gem install pg -v '0.14.1'
```

- gem install rspec2db-#{VERSION}.gem to install rspec2db gem (e.g. gem install rspec2db-0.1.3.gem)

- check rspec2db.yml (/rspec/config) configuration (db connection)

- create database if it does not already exist (it must match with database property specified in rspec2db.yml)

- execute rspec_db.rb (/rspec/config) to create tables and relations in the database (e.g.ruby rspec_db.rb)

- initialize your RSpec project (e.g. rspec --init), if you don't have one already

- copy /rspec/config/rspec2db.yml to your rspec project (e.g. ./config/rspec2db.yml)

- check that .rspec file contains following:
```
--require rspec2db
--format Rspec2db
--options ./config/rspec2db.yml #--options with location to rspec2db.yml relative to .rspec file
```

- run RSpec tests using the rspec command (from the location where .rspec file exist, to be able to pick up parameters defined in .rspec) (e.g. rspec spec/spec_spec.rb)

## Retrieve results from database

To retrieve test results from the database, you can use build_execution_stats.rb script which is located in “config” directory.
To execute the script, run the following command:

```
ruby config/build_execution_stats.rb <build_number> <results_file>
```

To execute the script with all optional parameters, run the following command:
```
ruby config/build_execution_stats.rb <build_number> <results_file>
 <results_aggregation> <test_reporter_url>
```

- build_number is a user specified value which needs to be the same like the one found in rspec2db.yml configuration file
- results_file is name of the file in which results are written
- results_aggregation (optional) determines if the statistics will be calculated for a single run with same build_number or for all runs with same build_number: 
    - not specified - results for only one run (the first one) will be in the results file
    - all - results for all runs will be in the results file
- test_reporter_url (optional) is the url of the Test Reporter tool which can be used in conjunction with rspec2db gem. If you use this parameter, you need to specify base url of your Test Reporter instance (for example: http://testreporter:8080). Based on this url, script will generate exact url path to this specific run which contains list of tests that have been executed

## Rspec2DB CLI

Rspec2db provides a CLI tool that helps users with bootstraping by generating configuration files. 

```
$ rspec2db
Loading default rspec2db configuration.
Using project config file
No command provided
Usage: rspec2db [options] <command>

init    - initialize rspec2db config file (~/.rspec2db.yaml)
create  - creates rspec2db database
migrate - migrates rspec2db database
build-stats - extracts test run execution based on test run id

Options:
    -H, --host=h                     rspec2db database host
    -p, --port=port                  rspec2db database port
    -d, --database=db                rspec2db database name
    -u, --username=u                 rspec2db database username
    -w, --password=pw                rspec2db database user password
    -a, --adapter=ad                 rspec2db database adapter
    -h, --help                       rspec2db help
```
### Usage
The tool provides number of options for onboarding:
1. `init` - Initialization of a global configuration file (stored in the home directory) with predefined configuration, and should be modifed (ie. values in `~/.rspec2db.yml` should be changed). This will also add Rspec2db formater to your spec `.rspec` file
2. `create` - Rake-like task that will create and seed the db.
3. `migrate` - Rake-like task that will migrate latest changes to the db
3. `build-stats` - Export of Test execution results and statistics for a Test build

### Other
DB tasks and Export load the rspec2db configuration file that is either defined in the `.rspec` file in your spec directory, or loads the default configuration file in your home directory.
Default configuration (from the `rspec2db.yaml`) can be overriden using the provided CLI options for targeting a specific DB (ie. by providing host, port, db credentials and similar).

