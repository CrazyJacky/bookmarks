require 'rack'
require 'thin'

require './server.rb'
run Server.new