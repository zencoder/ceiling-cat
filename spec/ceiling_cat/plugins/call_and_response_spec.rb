require 'spec_helper'
require 'ceiling_cat/plugins/call_and_response'

describe "Call and Response" do
  before(:each) do
    CeilingCat::Storage::Hash.send "clear" # Clear the calls and response each time.

    subdomain = "subdomain"
    token = "1234abcd"
    plugins = [CeilingCat::Plugin::CallAndResponse]

    FakeWeb.register_uri(:get, "https://#{token}:X@#{subdomain}.campfirenow.com/rooms.json", :body => fixture('campfire/rooms.json'), :status => ["200"])
    FakeWeb.register_uri(:get, "https://#{token}:X@#{subdomain}.campfirenow.com/users/me.json", :body => fixture('campfire/me.json'), :status => ["200"])

    @connection = CeilingCat::Campfire::Connection.new(OpenStruct.new({:service => 'campfire', :subdomain => subdomain, :token => token, :room => 'Room 1', :plugins => plugins}))
    @room = CeilingCat::Campfire::Room.new(:connection => @connection, :room_name => @connection.config.room)
  end

  describe "base methods" do
    it "should add a call and response" do
      CeilingCat::Plugin::CallAndResponse.add(:call => "foo", :response => "bar")
      CeilingCat::Plugin::CallAndResponse.list.should include({:call => "foo", :response => "bar"})
    end

    it "should remove a call and response" do
      CeilingCat::Plugin::CallAndResponse.add(:call => "foo", :response => "bar")
      CeilingCat::Plugin::CallAndResponse.list.should include({:call => "foo", :response => "bar"})
      CeilingCat::Plugin::CallAndResponse.remove("foo")
      CeilingCat::Plugin::CallAndResponse.list.should_not include({:call => "foo", :response => "bar"})
    end
  end

  describe "commands" do
    before(:each) do
      CeilingCat::Plugin::CallAndResponse.add(:call => "foo", :response => "bar")
    end

    describe "from a guest user" do
      before(:each) do
        @guest_user = CeilingCat::User.new("Guest", :id => 12345, :role => "guest")
      end

      describe "calling the 'list calls' command" do
        it "should not say anything" do
          event = CeilingCat::Event.new(@room,"!list calls", @guest_user)
          @room.should_not_receive(:say)
          CeilingCat::Plugin::CallAndResponse.new(event).handle
        end
      end

      describe "calling the 'add call' command" do
        it "should not say anything" do
          event = CeilingCat::Event.new(@room,"!add call you say something | something witty", @guest_user)
          @room.should_not_receive(:say)
          CeilingCat::Plugin::CallAndResponse.new(event).handle
        end
      end

      describe "calling the 'remove call' command" do
        it "should not say anything" do
          event = CeilingCat::Event.new(@room,"!remove call you say something", @guest_user)
          @room.should_not_receive(:say)
          CeilingCat::Plugin::CallAndResponse.new(event).handle
        end
      end
    end

    describe "from a registered user" do
      before(:each) do
        @registered_user = CeilingCat::User.new("Guest", :id => 12345, :role => "member")
      end

      describe "calling the 'list calls' command" do
        it "should list the calls" do
          event = CeilingCat::Event.new(@room,"!list calls", @registered_user)
          @room.should_receive(:say).with(["Current Calls and Responses", "-- foo | bar"])
          CeilingCat::Plugin::CallAndResponse.new(event).handle
        end
      end

      describe "calling the 'add call' command" do
        it "should add a call" do
          event = CeilingCat::Event.new(@room,"!add call you say something | something witty", @registered_user)
          @room.should_receive(:say).with("Call and Response added.")
          CeilingCat::Plugin::CallAndResponse.new(event).handle
        end
      end

      describe "calling the 'remove call' command" do
        it "should remove a call" do
          event = CeilingCat::Event.new(@room,"!remove call you say something", @registered_user)
          @room.should_receive(:say).with("Call removed.")
          CeilingCat::Plugin::CallAndResponse.new(event).handle
        end
      end
    end
  end

  describe "matching" do
    before(:each) do
      @call = "Who's the cat that won't cop out when there's danger all about?"
      @response = "SHAFT!"
      CeilingCat::Plugin::CallAndResponse.add(:call => @call, :response => @response)
    end

    describe "only the call is said" do
      it "should say the response" do
        event = CeilingCat::Event.new(@room, @call, @registered_user)
        @room.should_receive(:say).with(@response)
        CeilingCat::Plugin::CallAndResponse.new(event).handle
      end
    end

    describe "the call is said midsentence" do
      it "should say the response" do
        event = CeilingCat::Event.new(@room, "Who are they talking about when they ask #{@call.downcase}", @registered_user)
        @room.should_receive(:say).with(@response)
        CeilingCat::Plugin::CallAndResponse.new(event).handle
      end
    end

    describe "when the call includes regex" do
      it "should say the response" do
        CeilingCat::Plugin::CallAndResponse.add(:call => "foo+", :response => @response)
        event = CeilingCat::Event.new(@room, "fooooooooooooo", @registered_user)
        @room.should_receive(:say).with(@response)
        CeilingCat::Plugin::CallAndResponse.new(event).handle
      end
    end
  end

  describe "responding" do
    it "should support old-style responses" do
      @call = "Who's the cat that won't cop out when there's danger all about?"
      @response = "SHAFT!"
      CeilingCat::Plugin::CallAndResponse.add(:call => @call, :response => @response)

      event = CeilingCat::Event.new(@room, @call, @registered_user)
      @room.should_receive(:say).with(@response)
      CeilingCat::Plugin::CallAndResponse.new(event).handle
    end

    it "should support new-style responses" do
      @call = "Who's the cat that won't cop out when there's danger all about?"
      @response = ["SHAFT!", "BATMAN!"]
      CeilingCat::Plugin::CallAndResponse.add(:call => @call, :response => @response)

      event = CeilingCat::Event.new(@room, @call, @registered_user)
      @room.should_receive(:say).with(/#{@response.join("|")}/)
      CeilingCat::Plugin::CallAndResponse.new(event).handle
    end
  end
end