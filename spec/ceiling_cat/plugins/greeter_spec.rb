require 'spec_helper'
require 'ceiling_cat/plugins/greeter'

describe "Greeter" do
  before(:each) do
    CeilingCat::Storage::Hash.send "clear" # Clear the calls and response each time.

    user = "user"
    token = "1234abcd"
    plugins = [CeilingCat::Plugin::Greeter]

    FakeWeb.register_uri(:get, "https://#{token}:X@#{user}.campfirenow.com/rooms.json", :body => fixture('campfire/rooms.json'), :status => ["200"])
    FakeWeb.register_uri(:get, "https://#{token}:X@#{user}.campfirenow.com/room/80749.json", :body => fixture('campfire/room.json'), :status => ["200"])
    FakeWeb.register_uri(:get, "https://#{token}:X@#{user}.campfirenow.com/users/me.json", :body => fixture('campfire/me.json'), :status => ["200"])

    @connection = CeilingCat::Campfire::Connection.new(OpenStruct.new({:service => 'campfire', :username => user, :token => token, :room => 'Room 1', :plugins => plugins}))
    @room = CeilingCat::Campfire::Room.new(:connection => @connection, :room_name => @connection.config.room)
  end

  describe "room entrance" do
    describe "from a guest user" do
      before(:each) do
        @guest_user = CeilingCat::User.new("Guest", :id => 12345, :role => "guest")
      end

      it "should say hello!" do
        event = CeilingCat::Event.new(@room, nil, @guest_user, :type => :entrance)
        @room.should_receive(:say).with(["Hey Guest!"])
        CeilingCat::Plugin::Greeter.new(event).handle
      end
    end
    
    describe "from a registered user" do
      before(:each) do
        @guest_user = CeilingCat::User.new("Member", :id => 12345, :role => "member")
      end

      it "should say hello!" do
        event = CeilingCat::Event.new(@room, nil, @guest_user, :type => :entrance)
        @room.should_receive(:say).with(["Nice to see you again Member"])
        CeilingCat::Plugin::Greeter.new(event).handle
      end
    end
  end
end