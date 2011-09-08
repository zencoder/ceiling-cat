# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ceiling_cat/version"

Gem::Specification.new do |s|
  s.name        = "ceiling_cat"
  s.version     = CeilingCat::VERSION
  s.authors     = ["Chris Warren"]
  s.email       = ["chris@zencoder.com"]
  s.homepage    = "http://zencoder.com"
  s.summary     = %q{Ceiling Cat is watching you chat. A Campfire and IRC chat bot.}
  s.description = %q{Ceiling Cat is watching you chat. A Campfire and IRC chat bot!}

  s.post_install_message = <<eos
  ********************************************************************************
    Run `ceiling_cat setup` to create a Chatfile and a Rakefile - everything you
    need to start watching your chats and making ceiling_cat do your bidding!

    Update your Chatfile with your credentials and you'll be ready to go!

    Want Ceiling Cat to do something special just for you?
    Run `rake plugin:create name=plugin_name` to generate a new plugin.
  ********************************************************************************
eos

  s.add_dependency "tinder", "1.6.0"
  s.add_dependency "httparty", "0.7.8"
  s.add_dependency "crack", "0.1.8"
  s.add_dependency "irc-socket", "1.0.1"

  s.add_development_dependency "rspec", "2.6.0"
  s.add_development_dependency "ruby-debug"
  s.add_development_dependency "fakeweb"

  s.files         = Dir.glob("{lib,setup}/**/*").reject{|f| File.directory?(f) }
  s.test_files    = []
  s.executables   = ["ceiling_cat"]
  s.require_paths = ["lib"]
end
