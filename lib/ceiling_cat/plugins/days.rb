module CeilingCat
  class NotADateError < CeilingCatError; end
  
  module Plugin
    class Days < CeilingCat::Plugin::Base
      def self.commands
        [{:regex => "today", :name => "today", :description => "Find out if there's anything special about today.", :method => "about"},
         {:regex => "add holiday", :name => "add holiday", :description => "Add a holiday - '!add holiday 1/19/2011'", :method => "add_to_holidays"}]
      end
      
      def about(date=Date.today)
        begin
          if self.class.is_a_holiday?(date)
            reply "Today is a holiday!"
          elsif self.class.is_a_weekend?(date)
            reply "Today is a weekend!"
          else
            reply "Just a normal day today."
          end
        rescue NotADateError
          reply "Sorry, that's not a valid date."
        end
      end
      
      def self.description
        "Holidays and times you shouldn't expect to see us in chat."
      end
      
      def add_to_holidays
        date = body_without_command(/^!add holiday/)
        if date.empty?
          reply "You need to provide a date to add to the holiday list, like 'add holiday 1/19/2011'"
        else
          begin
            self.class.add_to_holidays(body_without_command(/^!add holiday/))
            reply "#{date.to_s} has been added to the holiday list."
          rescue NotADateError
            reply "Sorry, that's not a valid date."
          end
        end
      end
      
      def self.is_a_weekend?(date=Date.today)
        if is_a_date?(date)
          date = Date.parse(date.to_s)
          date.wday == 0 || date.wday == 6
        else
          raise NotADateError
        end
      end
      
      def self.holidays
        store["holidays"] ||= []
      end
      
      def self.add_to_holidays(days)
        dates = Array(days).collect do |day|
          if is_a_date?(day)
            Date.parse(day.to_s)
          else
            raise NotADateError
          end
        end

        store["holidays"] ||= []
        store["holidays"] = (store["holidays"] + dates).uniq
      end

      def self.remove_from_holidays(days)
        dates = Array(days).collect do |day|
          if is_a_date?(day)
            Date.parse(day.to_s)
          else
            raise NotADateError
          end
        end
        
        store["holidays"] ||= []
        store["holidays"] = store["holidays"] - dates
      end
      
      def self.is_a_holiday?(date=Date.today)
        if is_a_date?(date)
          store["holidays"].include? Date.parse(date.to_s)
        else
          raise NotADateError
        end
      end
      
      def self.is_a_date?(date_string)
        begin
          return true if Date.parse(date_string.to_s)
        rescue ArgumentError => e
          return false
        end
      end
    end
  end
end
