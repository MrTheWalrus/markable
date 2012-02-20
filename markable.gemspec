$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "markable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "markable"
  s.version     = Markable::VERSION
  s.authors     = ["Alex Chrome"]
  s.email       = ["dify.chrome@gmail.com"]
  s.homepage    = ""
  s.summary     = "Marking system for rails app"
  s.description = "Markable allows you to easily create a marking system in your rails application."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1"

  s.add_development_dependency "sqlite3"
end
