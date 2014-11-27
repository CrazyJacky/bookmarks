source 'http://rubygems.org'


gem 'data_mapper'
gem 'sinatra'
gem 'thin'
gem 'tux'

group :production do
  gem 'dm-postgres-adapter'
  gem 'pg'
end

group :development, :test do
  gem 'sqlite3'
  gem 'dm-sqlite-adapter'
end
