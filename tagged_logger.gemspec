# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "tagged_logger"
  s.version     = "0.3.2"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Aleksandr Furmanov"]
  s.email       = ["aleksandr.furmanov@gmail.com"]
  s.homepage    = "http://github.com/afurmanov/tagged_logger"
  s.summary     = %{Detaches _what_ is logged from _how_ it is logged}
  s.description = %{Detaches _what_ is logged from _how_ it is logged}
  s.required_rubygems_version = ">= 1.3.6"
  s.add_dependency "hashery"
  s.add_development_dependency "shoulda"
  s.add_development_dependency "rr"
  s.files = Dir["[A-Z]*", "{lib,test,examples}/**/*"]
end

