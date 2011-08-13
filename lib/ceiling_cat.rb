# General
%w{version setup connection errors event user room plugins/base services/campfire}.each do |file|
  require "ceiling_cat/#{file}"
end