require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :development)

require 'ceiling_cat'
require 'ceiling_cat/storage/hash'

FakeWeb.allow_net_connect = false

def fixture(name)
  File.read(File.dirname(__FILE__) + "/fixtures/#{name}")
end

RSpec.configure do |c|
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
end