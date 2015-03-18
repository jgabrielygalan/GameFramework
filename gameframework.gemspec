# -*- coding: utf-8 -*-

Gem::Specification.new do |spec|
    spec.add_dependency 'thin'
    spec.add_dependency 'sinatra'
    spec.add_dependency 'sinatra-contrib'
    spec.add_dependency 'mongoid'  
    spec.add_development_dependency 'bundler'
    spec.authors = ['Jesús Gabriel y Galán']
    spec.description = 'A Ruby game framework for playing games'
    spec.email = %w(mail)
    spec.files = %w(LICENSE.md README.md gameframework.gemspec) + Dir["{bin,lib,t}/**/*"]
    spec.homepage = 'https://github.com/jgabrielygalan/GameFramework'
    spec.licenses = %w(MIT)
    spec.name = 'gameframework'
    spec.require_paths = %w(lib)
    spec.required_ruby_version = '>= 1.9.3'
    spec.summary = File.read(File.join(File.dirname(__FILE__), 'README'))
    spec.version = '0.1.1'
end
