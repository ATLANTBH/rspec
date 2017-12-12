class TestRun < ActiveRecord::Base
  has_many :testcases
  belongs_to :testsuite
end
