require 'spec_helper'
require 'ceiling_cat/plugins/days'

describe "Days" do
  before(:each) do
    CeilingCat::Storage::Hash.send "clear" # Clear the calls and response each time.

    subdomain = "subdomain"
    token = "1234abcd"
    plugins = [CeilingCat::Plugin::Days]

    FakeWeb.register_uri(:get, "https://#{token}:X@#{subdomain}.campfirenow.com/rooms.json", :body => fixture('campfire/rooms.json'), :status => ["200"])
    FakeWeb.register_uri(:get, "https://#{token}:X@#{subdomain}.campfirenow.com/users/me.json", :body => fixture('campfire/me.json'), :status => ["200"])

    @connection = CeilingCat::Campfire::Connection.new(OpenStruct.new({:service => 'campfire', :subdomain => subdomain, :token => token, :room => 'Room 1', :plugins => plugins}))
    @room = CeilingCat::Campfire::Room.new(:connection => @connection, :room_name => @connection.config.room)
  end

  describe "base methods" do
    describe "holiday storage" do
      describe "adding a holiday" do
        it "should save with a parsable date" do
          CeilingCat::Plugin::Days.add_to_holidays("1/19/2011")
          @room.store["holidays"].should include(Date.parse("1/19/2011"))
        end

        it "should fail with a bad date/non-date" do
          lambda{ CeilingCat::Plugin::Days.add_to_holidays("My birthday") }.should raise_error CeilingCat::NotADateError
          @room.store["holidays"].should == nil
        end
      end

      describe "removing a holiday" do
        before(:each) do
          @room.store["holidays"] = [Date.parse("1/19/2011")]
        end

        it "should save with a parsable date" do
          CeilingCat::Plugin::Days.remove_from_holidays("1/19/2011")
          @room.store["holidays"].should == []
        end

        it "should fail with a bad date/non-date" do
          lambda{ CeilingCat::Plugin::Days.remove_from_holidays("My birthday") }.should raise_error CeilingCat::NotADateError
          @room.store["holidays"].should include(Date.parse("1/19/2011"))
        end
      end
    end

    describe "date checking" do
      describe "any strings" do
        it "should return true if Date.parse works" do
          CeilingCat::Plugin::Days.is_a_date?("8/24/2011").should == true
        end

        it "should return true if Date.parse works" do
          CeilingCat::Plugin::Days.is_a_date?("next tuesday").should == true
        end

        it "should return false if Date.parse fails" do
          CeilingCat::Plugin::Days.is_a_date?("someday").should == false
        end
      end

      describe "a week day" do
        it "the weekend check should return false" do
          CeilingCat::Plugin::Days.is_a_weekend?("8/24/2011").should == false
        end

        it "the holiday check should return false" do
          CeilingCat::Plugin::Days.is_a_holiday?("8/24/2011").should == false
        end
      end

      describe "a weekend holiday" do
        before(:each) do
          @holiday = "8/20/2011"
          CeilingCat::Plugin::Days.add_to_holidays(@holiday)
        end

        it "the weekend check should return true" do
          CeilingCat::Plugin::Days.is_a_weekend?(@holiday).should == true
        end

        it "the holiday check should return true" do
          CeilingCat::Plugin::Days.is_a_holiday?(@holiday).should == true
        end
      end

      describe "a week day holiday" do
        before(:each) do
          @holiday = "8/24/2011"
          CeilingCat::Plugin::Days.add_to_holidays(@holiday)
        end

        it "the weekend check should return false" do
          CeilingCat::Plugin::Days.is_a_weekend?(@holiday).should == false
        end

        it "the holiday check should return true" do
          CeilingCat::Plugin::Days.is_a_holiday?(@holiday).should == true
        end
      end
    end
  end

  describe "commands" do
    describe "from a guest user" do
      before(:each) do
        @guest_user = CeilingCat::User.new("Guest", :id => 12345, :role => "guest")
      end

      describe "calling the 'add holiday' command" do
        it "should not do or say anything" do
          event = CeilingCat::Event.new(@room,"!add holiday 1/19/2011", @guest_user)
          @room.should_not_receive(:say)
          CeilingCat::Plugin::Days.new(event).handle
          @room.store["holidays"].should == nil
        end
      end

      describe "calling the 'today' command" do
        describe "when today is a holiday" do
          it "should say today is a holiday" do
            CeilingCat::Plugin::Days.stub(:is_a_holiday?).and_return(true)

            event = CeilingCat::Event.new(@room,"!today", @guest_user)
            @room.should_receive(:say).with("Today is a holiday!")
            CeilingCat::Plugin::Days.new(event).handle
          end
        end

        describe "when today is a weekend" do
          it "should say today is a holiday" do
            CeilingCat::Plugin::Days.stub(:is_a_weekend?).and_return(true)

            event = CeilingCat::Event.new(@room,"!today", @guest_user)
            @room.should_receive(:say).with("Today is a weekend!")
            CeilingCat::Plugin::Days.new(event).handle
          end
        end

        describe "when today is a weekday" do
          it "should say today is a holiday" do
            CeilingCat::Plugin::Days.stub(:is_a_weekend?).and_return(false)

            event = CeilingCat::Event.new(@room,"!today", @guest_user)
            @room.should_receive(:say).with("Just a normal day today.")
            CeilingCat::Plugin::Days.new(event).handle
          end
        end
      end
    end

    describe "from a registered user" do
      before(:each) do
        @registered_user = CeilingCat::User.new("Guest", :id => 12345, :role => "member")
      end

      describe "calling the 'add holiday' command" do
        it "should add a holiday" do
          holiday = "1/19/2011"
          event = CeilingCat::Event.new(@room,"!add holiday #{holiday}", @registered_user)
          @room.should_receive(:say).with("#{holiday} has been added to the holiday list.")
          CeilingCat::Plugin::Days.new(event).handle
          @room.store["holidays"].should include(Date.parse(holiday))
        end
      end

      describe "calling the 'today' command" do
        describe "when today is a holiday" do
          it "should say today is a holiday" do
            CeilingCat::Plugin::Days.stub(:is_a_holiday?).and_return(true)

            event = CeilingCat::Event.new(@room,"!today", @registered_user)
            @room.should_receive(:say).with("Today is a holiday!")
            CeilingCat::Plugin::Days.new(event).handle
          end
        end

        describe "when today is a weekend" do
          it "should say today is a holiday" do
            CeilingCat::Plugin::Days.stub(:is_a_weekend?).and_return(true)

            event = CeilingCat::Event.new(@room,"!today", @registered_user)
            @room.should_receive(:say).with("Today is a weekend!")
            CeilingCat::Plugin::Days.new(event).handle
          end
        end

        describe "when today is a weekday" do
          it "should say today is a holiday" do
            CeilingCat::Plugin::Days.stub(:is_a_weekend?).and_return(false)

            event = CeilingCat::Event.new(@room,"!today", @registered_user)
            @room.should_receive(:say).with("Just a normal day today.")
            CeilingCat::Plugin::Days.new(event).handle
          end
        end
      end
    end
  end
end