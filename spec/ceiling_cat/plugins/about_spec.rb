require 'spec_helper'
require 'ceiling_cat/plugins/about'

describe "About" do
  before(:each) do
    user = "user"
    token = "1234abcd"
    plugins = [CeilingCat::Plugin::About, CeilingCat::Plugin::General]
    
    FakeWeb.register_uri(:get, "https://#{token}:X@#{user}.campfirenow.com/rooms.json", :body => fixture('campfire/rooms.json'), :status => ["200"])
    FakeWeb.register_uri(:get, "https://#{token}:X@#{user}.campfirenow.com/users/me.json", :body => fixture('campfire/me.json'), :status => ["200"])
    
    @connection = CeilingCat::Campfire::Connection.new(OpenStruct.new({:service => 'campfire', :username => user, :token => token, :room => 'Room 1', :plugins => plugins}))
    @room = CeilingCat::Campfire::Room.new(:connection => @connection, :room_name => @connection.config.room)
  end

  describe "a guest user" do
    before(:each) do
      @guest_user = CeilingCat::User.new("Guest", :id => 12345, :role => "guest")
    end

    describe "calling the plugins command" do
      it "should not say anything" do
        event = CeilingCat::Event.new(@room,"!plugins", @guest_user)
        @room.should_not_receive(:say)
        response = CeilingCat::Plugin::About.new(event).handle
      end
    end
    
    describe "calling the commands command" do
      it "should not list public commands" do
        event = CeilingCat::Event.new(@room,"!commands", @guest_user)
        @room.should_receive(:say).with(@room.available_commands+["Run commands with '![command]' or '#{@room.me.name}: [command]'"])
        response = CeilingCat::Plugin::About.new(event).handle
      end
    end
  end
  
  describe "a registered user" do
    before(:each) do
      @registered_user = CeilingCat::User.new("Guest", :id => 12345, :role => "member")
    end

    describe "calling the plugins command" do
      it "should not say anything" do
        event = CeilingCat::Event.new(@room,"!plugins", @registered_user)
        @room.should_receive(:say).with(@room.plugin_descriptions(true))
        response = CeilingCat::Plugin::About.new(event).handle
      end
    end
    
    describe "calling the commands command" do
      it "should not list public commands" do
        event = CeilingCat::Event.new(@room,"!commands", @registered_user)
        @room.should_receive(:say).with(@room.available_commands(true)+["Run commands with '![command]' or '#{@room.me.name}: [command]'"])
        response = CeilingCat::Plugin::About.new(event).handle
      end
    end
  end
end