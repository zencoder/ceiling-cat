%w{connection room event}.each do |file|
  require "ceiling_cat/services/irc/#{file}"
end