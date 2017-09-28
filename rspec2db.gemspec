Gem::Specification.new do |s|
  s.name        = 'rspec2db'
  s.version     = '1.1.3'
  s.date        = '2016-10-06'
  s.summary     = "Save your RSpec test results to a database"
  s.description = "A simple RSpec formatter to enable writing RSpec test results to any database using ActiveRecord. Specify DB connection in a yml file and put path to that file as --options PATH in your .rspec file"
  s.authors     = ["Nermin Caluk", "Bakir Jusufbegovic"]
  s.email       = 'bakir@atlantbh.com'
  s.files       = ["lib/rspec2db.rb"]
  s.homepage    = 'https://github.com/ATLANTBH/rspec'

  s.add_dependency 'activerecord', '~> 5.1.3'
  s.add_dependency 'pg', '~>0.21.0'
  s.add_dependency 'activerecord-postgresql-adapter' 
  s.add_dependency 'rspec', '>= 3.0.0'
end
