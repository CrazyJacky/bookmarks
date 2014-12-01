require 'data_mapper'
require "dm-serializer"

require_relative 'users'
require_relative 'bookmarks'
require_relative 'tags'
require_relative 'taggings'




c_dir = File.dirname(__FILE__)
db_dir = c_dir + "/../db"

configure :development do
  DataMapper::setup(:default, "sqlite3://#{db_dir}/bookmarks.db")
end

configure :production do
  DataMapper::setup(:default, "postgres://bjjtxhuqcemetk:qapOhCoSMPmrRp8kVYFRgI1eiP@ec2-54-221-206-165.compute-1.amazonaws.com:5432/d9mkc83pd75vnk")
end

DataMapper.finalize.auto_upgrade!