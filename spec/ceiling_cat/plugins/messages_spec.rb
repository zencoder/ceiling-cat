require 'spec_helper'
require 'ceiling_cat/plugins/messages'

describe "Messages" do
  before(:each) do
    CeilingCat::Storage::Hash.send "clear" # Clear the storage

    subdomain = "subdomain"
    token = "1234abcd"
    plugins = [CeilingCat::Plugin::Messages]

    FakeWeb.register_uri(:get, "https://#{token}:X@#{subdomain}.campfirenow.com/rooms.json", :body => fixture('campfire/rooms.json'), :status => ["200"])
    FakeWeb.register_uri(:get, "https://#{token}:X@#{subdomain}.campfirenow.com/room/80749.json", :body => fixture('campfire/room.json'), :status => ["200"])
    FakeWeb.register_uri(:get, "https://#{token}:X@#{subdomain}.campfirenow.com/users/me.json", :body => fixture('campfire/me.json'), :status => ["200"])

    @connection = CeilingCat::Campfire::Connection.new(OpenStruct.new({:service => 'campfire', :subdomain => subdomain, :token => token, :room => 'Room 1', :plugins => plugins}))
    @room = CeilingCat::Campfire::Room.new(:connection => @connection, :room_name => @connection.config.room)
  end

  describe "base methods" do
    it "should save and list a message" do
      CeilingCat::Plugin::Messages.add(:to => "Anna", :from => "Dutch", :body => "Get to the choppa!")
      CeilingCat::Plugin::Messages.list.should include({:to => "Anna", :from => "Dutch", :body => "Get to the choppa!"})
    end
    
    it "should search messages" do
      CeilingCat::Plugin::Messages.add(:to => "Anna", :from => "Dutch", :body => "Get to the choppa!")
      CeilingCat::Plugin::Messages.add(:to => "Dutch", :from => "Predator", :body => "clikclikclikclikclik")
      CeilingCat::Plugin::Messages.messages_for("Anna").should == [{:to => "Anna", :from => "Dutch", :body => "Get to the choppa!"}]
    end
  end

  describe "commands" do
    # Tests for commands
    describe "from a guest user" do
      before(:each) do
        @guest_user = CeilingCat::User.new("Guest", :id => 12345, :role => "guest")
      end

      describe "calling the 'message for' command" do
        it "should save a message if the receipient isn't around" do
          event = CeilingCat::Event.new(@room,"!message for Chris Warren: You need to update Ceiling Cat.", @guest_user)
          @room.should_receive(:say).with("Message saved! I'll deliver it the next time Chris Warren is around.")
          CeilingCat::Plugin::Messages.new(event).handle
          CeilingCat::Plugin::Messages.list.should include({:to => "Chris Warren", :from => "Guest", :body => "You need to update Ceiling Cat."})
        end
        
        it "should not save a message if the receipient is around" do
          event = CeilingCat::Event.new(@room,"!message for Jane Doe: You need to update Ceiling Cat.", @guest_user)
          @room.should_receive(:say).with("Why leave that messsage? Jane Doe is here!")
          CeilingCat::Plugin::Messages.new(event).handle
          CeilingCat::Plugin::Messages.list.should == []
        end
      end
    end

    describe "from a registered user" do
      before(:each) do
        @registered_user = CeilingCat::User.new("Member", :id => 12345, :role => "member")
      end

      describe "calling the 'message for' command" do
        it "save a message if the recipient isn't around" do
          event = CeilingCat::Event.new(@room,"!message for Chris Warren: You need to update Ceiling Cat.", @registered_user)
          @room.should_receive(:say).with("Message saved! I'll deliver it the next time Chris Warren is around.")
          CeilingCat::Plugin::Messages.new(event).handle
          CeilingCat::Plugin::Messages.list.should include({:to => "Chris Warren", :from => "Member", :body => "You need to update Ceiling Cat."})
        end
        
        it "should not save a message if the receipient is around" do
          event = CeilingCat::Event.new(@room,"!message for Jane Doe: You need to update Ceiling Cat.", @registered_user)
          @room.should_receive(:say).with("Why leave that messsage? Jane Doe is here!")
          CeilingCat::Plugin::Messages.new(event).handle
          CeilingCat::Plugin::Messages.list.should == []
        end
      end
    end
  end

  describe 'entrance and exit' do
    # Tests for things to run when a user enters or exits the room
    describe "entering the room" do
      describe "as a guest" do
        before(:each) do
          CeilingCat::Plugin::Messages.add(:to => "Anna", :from => "Dutch", :body => "Get to the choppa!")
          @guest_user = CeilingCat::User.new("Anna", :id => 12345, :role => "guest", :type => :entrance)
          @event = CeilingCat::Event.new(@room, nil, @guest_user, :type => :entrance)
        end
        
        it "should deliver the message and return a response of false" do
          @room.should_receive(:say).with(["Hey Anna! I have a message to deliver to you:", "From Dutch: Get to the choppa!"])
          response = CeilingCat::Plugin::Messages.new(@event).handle
          response.should == false
        end
      end
      
      describe "as a member" do
        before(:each) do
          CeilingCat::Plugin::Messages.add(:to => "Anna", :from => "Dutch", :body => "Get to the choppa!")
          @registered_user = CeilingCat::User.new("Anna", :id => 12345, :role => "member", :type => :entrance)
          @event = CeilingCat::Event.new(@room, nil, @registered_user, :type => :entrance)
        end
        
        it "should deliver the message and return a response of false" do
          @room.should_receive(:say).with(["Hey Anna! I have a message to deliver to you:", "From Dutch: Get to the choppa!"])
          response = CeilingCat::Plugin::Messages.new(@event).handle
          response.should == false
        end
      end
    end
  end
end
