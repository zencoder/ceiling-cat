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
        "lib/ceiling_cat/plugins/base.rb"]

plugins = ["lib/ceiling_cat/plugins/about.rb",
           "lib/ceiling_cat/plugins/calc.rb",
           "lib/ceiling_cat/plugins/notifo.rb",
           "lib/ceiling_cat/plugins/zencoder_status.rb",
           "lib/ceiling_cat/plugins/greeter.rb"]
 
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

  s.rubyforge_project = "ceiling_cat"
  
  s.add_dependency "tinder"
  s.add_dependency "httparty"
  s.add_dependency "crack"

  s.files         = base + plugins + campfire
  s.test_files    = []
  s.executables   = ["ceiling_cat"]
  s.require_paths = ["lib"]
end
