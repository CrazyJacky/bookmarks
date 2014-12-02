require 'data_mapper'
require "dm-serializer"

require_relative 'users'
require_relative 'bookmarks'
require_relative 'tags'
require_relative 'taggings'




c_dir = File.dirname(__FILE__)
db_dir = c_dir + "/../db"

configure :development do
  DataMapper::setup(:default, "sqlite3://#{db_dir}/bookmarksh.db")
end

configure :production do
  DataMapper::setup(:default, "postgres://trfoajmntjazdy:ufLWnpJfMlDygGunJ5YdlpVJwA@ec2-54-243-51-102.compute-1.amazonaws.com:5432/dbibra39e733iq")
end

DataMapper.finalize.auto_upgrade!