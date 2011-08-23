# General
%w{version setup connection errors event user room plugins/base services/campfire storage/base storage/hash storage/yaml}.each do |file|
  require "ceiling_cat/#{file}"
end