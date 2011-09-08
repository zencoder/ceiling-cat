require 'spec_helper'
require 'ceiling_cat/services/irc/room'

describe "IRC Room" do
  before(:each) do
    @connection = CeilingCat::IRC::Connection.new(OpenStruct.new({:service => 'irc', :room => '#room_1', :nick => "test bot"}))
    @room = CeilingCat::IRC::Room.new(:connection => @connection, :room_name => @connection.config.room)
  end

  describe "parsing messages" do
    it "gets name, body, and event type from a chat message" do
      parts = @room.message_parts(":chriswarren!~chriswarr@50.0.132.2 PRIVMSG #ceilingcat_test :!status")
      parts[:name].should == "chriswarren"
      parts[:body].should == "!status"
      parts[:type].should == :chat
    end

    it "gets name, body, and event type from a JOIN message" do
      parts = @room.message_parts(":chriswarren!~chriswarr@50.0.132.2 JOIN :#ceilingcat_test")
      parts[:name].should == "chriswarren"
      parts[:body].should == nil
      parts[:type].should == :entrance
    end
  end
end