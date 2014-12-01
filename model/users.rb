require 'data_mapper'
require "bcrypt"

class User
  include DataMapper::Resource
  include BCrypt
  property :id, Serial
  property :username, String, :required => true, :unique => true, length: 50
  property :password, BCryptHash, :required => true

  has n, :bookmarks, :constraint => :destroy


  def authenticate(attempted_password)
    if self.password == attempted_password
      true
    else
      false
    end
  end

end

