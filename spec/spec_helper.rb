require 'rubygems'
require 'ruby-debug'

require 'rspec'
require 'ceiling_cat'
require 'fakeweb'

require 'ceiling_cat/storage/hash'

FakeWeb.allow_net_connect = false

def fixture(name)
  File.read(File.dirname(__FILE__) + "/fixtures/#{name}")
end
