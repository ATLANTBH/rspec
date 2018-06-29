rspec2db: RSpec DB Formatter
============================


## Description
rspec2db is a Ruby gem used for storing rspec test execution results to a database. This gem extends RSpec formatter and has to be required in `.rspec` (which is done by rspec2db init command described below). Once added, the gem will handle storing all test related informations (test suites, test cases, test steps) into the database. By default, rspec2db supports writing to postgresql database but can be easily adjusted to write results into other relational databases as well since it uses ActiveRecord for persisting data.

The gem also provides a CLI tool meant for bootstrapping rspec2db configuration files.


## Rspec2DB CLI

Rspec2db provides a CLI tool that helps users with bootstraping by generating configuration files. 

```
$ rspec2db
Loading default rspec2db configuration.
Using project config file
No command provided
Usage: rspec2db [options] <command>

init    - initialize rspec2db config file (~/rspec2db.yaml)
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
1. `init` - Initialization of a global configuration file (stored in the home directory) with predefined configuration that can be modified (ie. values in `~/rspec2db.yaml` should be changed to appropriate values). This will also add Rspec2db formater to your spec `.rspec` file.
2. `create` - Rake-like task that will create and seed the db.
3. `migrate` - Rake-like task that will migrate latest changes to the db
3. `build-stats` - Export of Test execution results and statistics for a Test build

### Example

```
$ rspec2db init
Loading default rspec2db configuration.
Using project config file
No rspec2db config specified in .rspec
Loading default rspec2db options (/Users/user/rspec2db.yaml)
Creating default rspec2db config file (/Users/user/rspec2db.yaml)
Adding rspec2db options and formatter to .rspec
```

```
# Edit ~/rspec2db.yaml to use your PG database. Database has to exist before running create task.
$ rspec2db create
Loading default rspec2db configuration.
No project file detected. Looking for local config file
-- create_table(:test_suites, {:force=>:cascade})
   -> 0.1380s
-- create_table(:test_runs, {:force=>:cascade})
   -> 0.0513s
-- create_table(:test_cases, {:force=>:cascade})
   -> 0.0425s
```

```
# Migrate changes
$ rspec2db migrate
Loading default rspec2db configuration.
No project file detected. Looking for local config file
```

This flow will result in a configured PG Database and a configuration file that can be used among different projects.


To reuse the existing configuration file in a separate rspec spec project, simply run `rspec init`. This will configure your `.rspec` file:
`
```$ rspec2db init
bundle exec rspec2db init
Loading default rspec2db configuration.
No project file detected. Looking for local config file
No rspec2db config specified in .rspec
Loading default rspec2db options (/Users/user/rspec2db.yaml)
Default config file exists, override with default? (Y/N)
N
Adding rspec2db options and formatter to .rspec
```

## Other
Rspec2DB CLI commands load the rspec2db configuration file that is either defined in the `.rspec` file in your spec directory, or loads the default configuration file in your home directory.
Default configuration (from the `rspec2db.yaml`) can be overriden using the provided CLI options for targeting a specific DB (ie. by providing host, port, db credentials and similar).

### Using the formatter
`rspec2db init` will add `rspec2db` formatter to `.rspec` file, resulting in every spec that is ran by `rspec spec/*` to be written to the database (in the format of test suites, test cases and test steps). 

#### Retrieve results from database

To retrieve test results from the database, you can use RSpec2DB CLI command `build-stats`.
To execute the script, run the following command:
```
$ rspec2db build-stats --help
Loading default rspec2db configuration.
No project file detected. Looking for local config file
Usage: rspec2db [options]
    -i, --id=id                      rspec2db test build id
    -o, --output file                rspec2db extract output file
    -l, --limit [LIMIT]              rspec2db number of extracted test runs
    -s, --suite suite                rspec2db test suite
    -U [url]--URL [url]              Test Reporter (www.github.com/ATLANTBH/owl) url link

```


To execute the script with all optional parameters, run the following command:

```
rspec2db build-stats -i <build_number> -l <limit> -o <output_file> -s <test_suite> -U <reporter_url>
```

- build_number is a user specified value which needs to be the same like the one found in rspec2db.yml configuration file
- output_file is name of the file in which results are written
- limit (optional) determines if the statistics will be calculated for a single run with same build_number or for all runs with same build_number: 
    - not specified - results for only one run (the first one) will be in the results file
    - all - results for all runs will be in the results file
- test_suite is the name of the suite from which we want to query results
- reporter_url (optional) is the url of the Test Reporter tool which can be used in conjunction with rspec2db gem. If you use this parameter, you need to specify base url of your Test Reporter instance (for example: http://testreporter:8080). Based on this url, script will generate exact url path to this specific run which contains list of tests that have been executed
- suite_name - name of the test suite that was specified in `rspec2db.yml` file and for which the stats are calculated


### Updating Rspec2DB gem version

If you are updating Rspec2DB gem from a to a newer version, running `rspec2db migrate` is required. This command will migrate the database so that it satisfies the Rspec2DB model, if it was changed.

```
$ bundle update rspec2db
$ bundle exec rspec2db migrate
```
