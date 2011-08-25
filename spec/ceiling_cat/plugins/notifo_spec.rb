require 'spec_helper'
require 'ceiling_cat/plugins/notifo'

describe "Notifo" do
  before(:each) do
    CeilingCat::Storage::Hash.send "clear" # Clear the calls and response each time.

    user = "user"
    token = "1234abcd"
    plugins = [CeilingCat::Plugin::Notifo]

    FakeWeb.register_uri(:get, "https://#{token}:X@#{user}.campfirenow.com/rooms.json", :body => fixture('campfire/rooms.json'), :status => ["200"])
    FakeWeb.register_uri(:get, "https://#{token}:X@#{user}.campfirenow.com/users/me.json", :body => fixture('campfire/me.json'), :status => ["200"])

    @connection = CeilingCat::Campfire::Connection.new(OpenStruct.new({:service => 'campfire', :username => user, :token => token, :room => 'Room 1', :plugins => plugins}))
    @room = CeilingCat::Campfire::Room.new(:connection => @connection, :room_name => @connection.config.room)
  end

  describe "base methods" do
    describe "administrating users" do
      describe "adding users" do
        it "should save a single user" do
          CeilingCat::Plugin::Notifo.add_users("zencoder")
          @room.store["notifo_users"].should include("zencoder")
        end

        it "should save multiple users passed as an array" do
          CeilingCat::Plugin::Notifo.add_users(["zencoder", "tester"])
          @room.store["notifo_users"].should include("zencoder")
          @room.store["notifo_users"].should include("tester")
        end
      end

      describe "removing users" do
        before(:each) do
          @room.store["holidays"] = ["zencoder", "tester"]
        end

        it "should remove a single user" do
          CeilingCat::Plugin::Notifo.remove_users("zencoder")
          @room.store["notifo_users"].should_not include("zencoder")
        end

        it "should remove multiple users passed as an array" do
          CeilingCat::Plugin::Notifo.remove_users(["zencoder", "tester"])
          @room.store["notifo_users"].should_not include("zencoder")
          @room.store["notifo_users"].should_not include("tester")
        end
      end
    end

    describe "setting credentials" do
      it "should save the credentials" do
        CeilingCat::Plugin::Notifo.set_credentials("username","api_secret")
        @room.store["notifo_credentials"].should == {:username => "username", :api_secret => "api_secret"}
      end
    end

    describe "#active?" do
      describe "nothing set" do
        it "should be false" do
          CeilingCat::Plugin::Notifo.active?.should == false
        end
      end
      
      describe "credentials set without users" do
        it "should be false" do
          CeilingCat::Plugin::Notifo.set_credentials("username","api_secret")
          CeilingCat::Plugin::Notifo.active?.should == false
        end
      end
      
      describe "users set without credentials" do
        it "should be false" do
          CeilingCat::Plugin::Notifo.add_users("zencoder")
          CeilingCat::Plugin::Notifo.active?.should == false
        end
      end
      
      describe "users and credentials set" do
        it "should be true" do
          CeilingCat::Plugin::Notifo.add_users("zencoder")
          CeilingCat::Plugin::Notifo.set_credentials("username","api_secret")
          CeilingCat::Plugin::Notifo.active?.should == true
        end
      end
    end
  end

  describe "commands" do
    before(:each) do
      CeilingCat::Plugin::Notifo.add_users("ceiling_cat")
      CeilingCat::Plugin::Notifo.set_credentials("username","api_secret")
    end
    
    describe "from a guest user" do
      before(:each) do
        @guest_user = CeilingCat::User.new("Guest", :id => 12345, :role => "guest")
      end

      describe "calling the 'deliver' command" do
        it "should not do or say anything" do
          event = CeilingCat::Event.new(@room,"!deliver you should get in here.", @guest_user)
          @room.should_not_receive(:say)
          CeilingCat::Plugin::Notifo.new(event).handle
        end
      end

      describe "calling the 'add notifo user' command" do
        it "should not do or say anything" do
          event = CeilingCat::Event.new(@room,"!add notifo user zencoder", @guest_user)
          @room.should_not_receive(:say)
          CeilingCat::Plugin::Notifo.new(event).handle
        end
      end

      describe "calling the 'remove notifo user' command" do
        it "should not do or say anything" do
          event = CeilingCat::Event.new(@room,"!remove notifo user zencoder", @guest_user)
          @room.should_not_receive(:say)
          CeilingCat::Plugin::Notifo.new(event).handle
        end
      end

      describe "calling the 'list notifo users' command" do
        it "should not do or say anything" do
          event = CeilingCat::Event.new(@room,"!list notifo users", @guest_user)
          @room.should_not_receive(:say)
          CeilingCat::Plugin::Notifo.new(event).handle
        end
      end
    end
    
    describe "from a registered user" do
      before(:each) do
        @registered_user = CeilingCat::User.new("Member", :id => 12345, :role => "member")
      end

      describe "calling the 'notifo' command" do
        it "should send a message via notifo" do
          message = "you should get in here"
          event = CeilingCat::Event.new(@room,"!notifo #{message}", @registered_user)
          @room.should_not_receive(:say)
          CeilingCat::Plugin::Notifo.any_instance.should_receive(:deliver)
          HTTParty.stub(:post)
          CeilingCat::Plugin::Notifo.new(event).handle
        end
      end

      describe "calling the 'add notifo user' command" do
        it "should add a user" do
          event = CeilingCat::Event.new(@room,"!add notifo users zencoder", @registered_user)
          @room.should_receive(:say).with("zencoder added to notifo alerts.")
          CeilingCat::Plugin::Notifo.should_receive(:add_users).with(["zencoder"])
          CeilingCat::Plugin::Notifo.new(event).handle
        end
      end

      describe "calling the 'remove notifo user' command" do
        it "should remove a user" do
          event = CeilingCat::Event.new(@room,"!remove notifo users zencoder", @registered_user)
          @room.should_receive(:say).with("zencoder removed from notifo alerts.")
          CeilingCat::Plugin::Notifo.should_receive(:remove_users).with(["zencoder"])
          CeilingCat::Plugin::Notifo.new(event).handle
        end
      end

      describe "calling the 'list notifo users' command" do
        it "should list users" do
          event = CeilingCat::Event.new(@room,"!list notifo users", @registered_user)
          @room.should_receive(:say).with(["Notifo Users","-- ceiling_cat"])
          CeilingCat::Plugin::Notifo.new(event).handle
        end
      end
    end
  end
end