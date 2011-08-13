%w{connection room event}.each do |file|
  require "ceiling_cat/services/campfire/#{file}"
end