require 'spec_helper'

describe "Connection" do
  describe "creating an instance" do
    it "loads the Chatfile and sets config" do
      load 'fixtures/Chatfile'
      cc = CeilingCat::Setup.new
      cc.config.service.should == "campfire"
      cc.config.plugins.should include(CeilingCat::Plugin::About)
    end
  end
  
  describe "creating an instance" do
    it "uses the defaul if there's no storage option passed" do
      config = OpenStruct.new({:service => 'campfire', :subdomain => 'user', :token => '1234abcd', :room => 'Room'})
      cc = CeilingCat::Connection.new(config)
      cc.config.storage.should == CeilingCat::Storage::Hash
    end
  end
end