# General
%w{version setup connection errors event user room plugin/base}.each do |file|
  require "ceiling_cat/#{file}"
end

# Campfire
%w{connection room event}.each do |file|
  require "ceiling_cat/campfire/#{file}"
end
