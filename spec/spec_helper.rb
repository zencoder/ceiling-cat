require 'rubygems'
require 'ruby-debug'

require 'rspec'
require 'ceiling_cat'
require 'fakeweb'

FakeWeb.allow_net_connect = false

def fixture(name)
  File.read(File.dirname(__FILE__) + "/fixtures/#{name}")
end

def stub_connection(object, &block)
  @stubs ||= Faraday::Adapter::Test::Stubs.new

  object.connection.build do |builder|
    builder.use     Faraday::Request::JSON
    builder.use     Faraday::Response::Mashify
    builder.use     Faraday::Response::ParseJson
    builder.use     Faraday::Response::RaiseOnAuthenticationFailure
    builder.adapter :test, @stubs
  end

  block.call(@stubs)
end
