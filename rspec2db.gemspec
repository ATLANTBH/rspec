Gem::Specification.new do |s|
  s.name          = 'rspec2db'
  s.version       = '1.2.0'
  s.date          = '2018-01-01'
  s.summary       = 'Save your RSpec test results to a database'
  s.description   = 'A simple RSpec formatter to enable writing RSpec test results to any database using ActiveRecord. Specify DB connection in a yml file and put path to that file as --options PATH in your .rspec file'
  s.authors       = ['Nermin Caluk', 'Bakir Jusufbegovic', 'Adnan Muslija']
  s.email         = ['bakir@atlantbh.com', 'adnan.muslija@atlantbh.com']
  s.files         = ['lib/rspec2db.rb', 'bin/rspec2db', 'config/rspec2db.yml']
  s.executables   = ['rspec2db']
  s.files =  `git ls-files`.split("\n")
  s.homepage      = 'https://github.com/ATLANTBH/rspec'

  s.add_dependency 'activerecord', '~>5.1'
  s.add_dependency 'pg', '~>0.21'
  s.add_dependency 'activerecord-postgresql-adapter'
  s.add_dependency 'rspec', '>= 3.0'
  s.add_dependency 'pry'
  s.add_dependency 'pry-nav'
end
