# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ceiling_cat/version"

base = ["lib/ceiling_cat.rb",
        "lib/ceiling_cat/setup.rb",
        "lib/ceiling_cat/version.rb",
        "lib/ceiling_cat/connection.rb",
        "lib/ceiling_cat/errors.rb",
        "lib/ceiling_cat/event.rb",
        "lib/ceiling_cat/user.rb",
        "lib/ceiling_cat/room.rb",
        "lib/ceiling_cat/storage/base.rb" ]

setup = ["setup/Chatfile",
         "setup/Rakefile"]

plugins = ["lib/ceiling_cat/plugins/base.rb",
           "lib/ceiling_cat/plugins/about.rb",
           "lib/ceiling_cat/plugins/calc.rb",
           "lib/ceiling_cat/plugins/call_and_response.rb",
           "lib/ceiling_cat/plugins/campfire_account_monitor.rb",
           "lib/ceiling_cat/plugins/days.rb",
           "lib/ceiling_cat/plugins/greeter.rb",
           "lib/ceiling_cat/plugins/notifo.rb",]

storage = ["lib/ceiling_cat/storage/base.rb",
           "lib/ceiling_cat/storage/hash.rb",
           "lib/ceiling_cat/storage/yaml.rb"]

campfire = ["lib/ceiling_cat/services/campfire.rb",
            "lib/ceiling_cat/services/campfire/connection.rb",
            "lib/ceiling_cat/services/campfire/event.rb",
            "lib/ceiling_cat/services/campfire/room.rb"]

Gem::Specification.new do |s|
  s.name        = "ceiling_cat"
  s.version     = CeilingCat::VERSION
  s.authors     = ["Chris Warren"]
  s.email       = ["chris@zencoder.com"]
  s.homepage    = "http://zencoder.com"
  s.summary     = %q{Ceiling Cat is watching you chat. A Campfire chat bot.}
  s.description = %q{Ceiling Cat is watching you chat. A Campfire chat bot!}

  s.post_install_message = <<eos
  ********************************************************************************
    Run `ceiling_cat setup` to create a Chatfile and a Rakefile - everything you
    need to start watching your chats and making ceiling_cat do your bidding!

    Update your Chatfile with your credentials and you'll be ready to go!

    Want Ceiling Cat to do something special just for you?
    Run `rake plugin:create name=plugin_name` to generate a new plugin.
  ********************************************************************************
eos

  s.add_dependency "tinder", "1.4.4"
  s.add_dependency "httparty", "0.7.8"
  s.add_dependency "crack", "0.1.8"

  s.add_development_dependency "rspec", "2.6.0"
  s.add_development_dependency "ruby-debug"
  s.add_development_dependency "fakeweb"

  s.files         = base + setup + plugins + storage + campfire
  s.test_files    = []
  s.executables   = ["ceiling_cat"]
  s.require_paths = ["lib"]
end
