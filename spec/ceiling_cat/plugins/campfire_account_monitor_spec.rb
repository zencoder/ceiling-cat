require 'spec_helper'
require 'ceiling_cat/plugins/campfire_account_monitor'
require 'ceiling_cat/plugins/notifo'

describe "Campfire Account Monitor" do
  before(:each) do
    CeilingCat::Storage::Hash.send "clear" # Clear the calls and response each time.

    subdomain = "subdomain"
    token = "1234abcd"
    plugins = [CeilingCat::Plugin::CampfireAccountMonitor, CeilingCat::Plugin::Notifo]
    @user_limit = 25

    FakeWeb.register_uri(:get, "https://#{token}:X@#{subdomain}.campfirenow.com/rooms.json", :body => fixture('campfire/rooms.json'), :status => ["200"])
    FakeWeb.register_uri(:get, "https://#{token}:X@#{subdomain}.campfirenow.com/users/me.json", :body => fixture('campfire/me.json'), :status => ["200"])

    @connection = CeilingCat::Campfire::Connection.new(OpenStruct.new({:service => 'campfire', :subdomain => subdomain, :token => token, :room => 'Room 1', :plugins => plugins, :max_users => @user_limit}))
    @room = CeilingCat::Campfire::Room.new(:connection => @connection, :room_name => @connection.config.room)
    @guest_user = CeilingCat::User.new("Guest", :id => 12345, :role => "guest")
  end

  describe "a user enters chat" do
    it "should not do anything if the limit is not reach" do
      @connection.stub(:total_user_count).and_return(10)
      CeilingCat::Plugin::Notifo.any_instance.stub(:active?).and_return(true)
      @room.should_not_receive(:say)

      event = CeilingCat::Event.new(@room, nil, @guest_user, :type => :entrance)

      CeilingCat::Plugin::Notifo.any_instance.should_not_receive(:deliver)
      CeilingCat::Plugin::CampfireAccountMonitor.new(event).handle
    end

    it "should send a Notifo if the limit is approached" do
      @connection.stub!(:total_user_count).and_return(24)
      CeilingCat::Plugin::Notifo.any_instance.stub(:active?).and_return(true)
      @room.should_not_receive(:say)

      event = CeilingCat::Event.new(@room, nil, @guest_user, :type => :entrance)

      CeilingCat::Plugin::Notifo.any_instance.should_receive(:deliver).with("24 of 25 max connections to Campfire.")
      CeilingCat::Plugin::CampfireAccountMonitor.new(event).handle
    end
  end
end