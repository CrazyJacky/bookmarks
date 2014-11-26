require 'data_mapper'
require "dm-serializer"

require_relative 'bookmarks'
require_relative 'tags'
require_relative 'taggings'



c_dir = File.dirname(__FILE__)
db_dir = c_dir + "/../db"

DataMapper::setup(:default, "sqlite3://#{db_dir}/bookmarks.db")
DataMapper.finalize.auto_upgrade!