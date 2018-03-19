describe "Dummy describe" do # this spec file is just for test / demo purposes
  context "CoNtExT" do
    it "does nothing, within context" do
      1.should eql(1)
    end
  end 
  
  it "does nothing again" do
    1.should eql(1)
  end
  
  it "raises" do
    raise "oh no"
  end
  
  it "pends" do pending
  end
  
end