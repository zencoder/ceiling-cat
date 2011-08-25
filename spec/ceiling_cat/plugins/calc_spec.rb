require 'spec_helper'
require 'ceiling_cat/plugins/calc'

describe "Calc" do
  before(:each) do
    subdomain = "subdomain"
    token = "1234abcd"
    plugins = [CeilingCat::Plugin::Calc]
    
    FakeWeb.register_uri(:get, "https://#{token}:X@#{user}.campfirenow.com/rooms.json", :body => fixture('campfire/rooms.json'), :status => ["200"])
    FakeWeb.register_uri(:get, "https://#{token}:X@#{user}.campfirenow.com/users/me.json", :body => fixture('campfire/me.json'), :status => ["200"])
    
    @connection = CeilingCat::Campfire::Connection.new(OpenStruct.new({:service => 'campfire', :subdomain => subdomain, :token => token, :room => 'Room 1', :plugins => plugins}))
    @room = CeilingCat::Campfire::Room.new(:connection => @connection, :room_name => @connection.config.room)
  end

  describe "a user" do
    before(:each) do
      @guest_user = CeilingCat::User.new("Guest", :id => 12345, :role => "guest")
    end

    describe "calling the cald command" do
      it "should calculate" do
        event = CeilingCat::Event.new(@room,"!calculate 20*5", @guest_user)
        @room.should_receive(:say).with("20*5 = 100")
        CeilingCat::Plugin::Calc.new(event).handle
      end
      
      it "should strip out any non-math information" do
        event = CeilingCat::Event.new(@room,"!calculate 20*5 `ls`", @guest_user)
        @room.should_receive(:say).with("20*5 = 100")
        CeilingCat::Plugin::Calc.new(event).handle
      end
      
      it "should be friendly if the mathing fails" do
        event = CeilingCat::Event.new(@room,"!calculate the mass of your mom", @guest_user)
        @room.should_receive(:say).with("I don't think that's an equation. Want to try something else?")
        CeilingCat::Plugin::Calc.new(event).handle
      end
    end
  end
end