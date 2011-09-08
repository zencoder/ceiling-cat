require 'spec_helper'
require 'ceiling_cat/plugins/twss'
require 'twss'

describe "TWSS" do
  before(:each) do
    CeilingCat::Storage::Hash.send "clear" # Clear the calls and response each time.

    subdomain = "subdomain"
    token = "1234abcd"
    plugins = [CeilingCat::Plugin::TWSS]

    FakeWeb.register_uri(:get, "https://#{token}:X@#{subdomain}.campfirenow.com/rooms.json", :body => fixture('campfire/rooms.json'), :status => ["200"])
    FakeWeb.register_uri(:get, "https://#{token}:X@#{subdomain}.campfirenow.com/users/me.json", :body => fixture('campfire/me.json'), :status => ["200"])

    @connection = CeilingCat::Campfire::Connection.new(OpenStruct.new({:service => 'campfire', :subdomain => subdomain, :token => token, :room => 'Room 1', :plugins => plugins}))
    @room = CeilingCat::Campfire::Room.new(:connection => @connection, :room_name => @connection.config.room)
  end

  describe "commands" do
    # Tests for commands
    describe "from a guest user" do
      before(:each) do
        @guest_user = CeilingCat::User.new("Guest", :id => 12345, :role => "guest")
      end

      describe "says something that, out of context, could be what she said" do
        it "should respond accordingly" do
          event = CeilingCat::Event.new(@room,"well hurry up, you're not going fast enough", @guest_user)
          @room.should_receive(:say).with(/#{CeilingCat::Plugin::TWSS::RESPONSES.join("|")}/)
          CeilingCat::Plugin::TWSS.new(event).handle
        end
      end

      describe "says something that is totally innocuous, even out of context" do
        it "should not respond" do
          event = CeilingCat::Event.new(@room,"hey, did you resolve that ticket?", @guest_user)
          @room.should_not_receive(:say)
          CeilingCat::Plugin::TWSS.new(event).handle
        end
      end
    end

    describe "from a registered user" do
      before(:each) do
        @registered_user = CeilingCat::User.new("Guest", :id => 12345, :role => "member")
      end

      describe "says something that, out of context, could be what she said" do
        it "should respond accordingly" do
          event = CeilingCat::Event.new(@room,"well hurry up, you're not going fast enough", @registered_user)
          @room.should_receive(:say).with(/#{CeilingCat::Plugin::TWSS::RESPONSES.join("|")}/)
          CeilingCat::Plugin::TWSS.new(event).handle
        end
      end

      describe "says something that is totally innocuous, even out of context" do
        it "should not respond" do
          event = CeilingCat::Event.new(@room,"hey, did you resolve that ticket?", @registered_user)
          @room.should_not_receive(:say)
          CeilingCat::Plugin::TWSS.new(event).handle
        end
      end
    end
  end

end
