Gem::Specification.new do |s|
  s.name          = 'rspec2db'
  s.version       = '1.2.2'
  s.date          = '2019-08-27'
  s.summary       = 'Save your RSpec test results to a database'
  s.description   = 'A simple RSpec formatter to enable writing RSpec test results to any database using ActiveRecord'
  s.authors       = ['Bakir Jusufbegovic', 'Adnan Muslija', 'Nermin Caluk']
  s.email         = ['bakir@atlantbh.com', 'adnan.muslija@atlantbh.com']
  s.files         = ['lib/rspec2db.rb', 'bin/rspec2db', 'config/rspec2db.yml']
  s.executables   = ['rspec2db']
  s.files =  `git ls-files`.split("\n")
  s.homepage      = 'https://github.com/ATLANTBH/rspec'

  s.add_dependency 'activerecord', '>=5.1', '<7.0'
  s.add_dependency 'pg', '~>0.21'
  s.add_dependency 'activerecord-postgresql-adapter'
  s.add_dependency 'rspec', '>= 3.0'
end
