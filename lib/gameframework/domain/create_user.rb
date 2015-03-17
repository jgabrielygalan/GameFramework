require 'mongoid'
require_relative 'user'

Mongoid.load!("../../../config/mongoid.yml", :development)

name = ARGV.shift || raise("I need a user name")
password = ARGV.shift || raise("I need a user password")

User.new(name: name, password: password).save
