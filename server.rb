require 'sinatra'
require 'json'
require 'digest/md5'


class Server < Sinatra::Base



  #use Rack::Session::Pool, :expire_after  => 120

  require_relative 'model/init'

  before do
    headers 'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST'],
            'Access-Control-Allow-Headers' => 'Content-Type'
  end

begin
  configure do
    enable :sessions
    # set :usernameMD5, '9661fd65249b026ebea0f49927e82f0e'
    # set :passwordMD5, 'b9556622dad3756764860385651e95ae'
  end
end


  helpers do
    def add_tags(bookmark,data)

      labels = (data["tagList"] || "").split(",").map(&:strip)
      #puts labels
      # more code to come

      existing_labels = []
      #puts "Existing Lables: #{existing_labels}"
      bookmark.taggings.each do |tagging|
        puts "tagging: #{tagging}"
        if labels.include? tagging.tag.label
          existing_labels.push tagging.tag.label
        else
          tagging.destroy
        end
      end

      #puts "Existing Lables 2: #{existing_labels}"

      (labels - existing_labels).each do |label|

        #puts label
        tag = {:label => label}
        existing = Tag.first tag
        if !existing
          existing = Tag.create! tag
        end
        Tagging.create! :tag => existing, :bookmark => bookmark
      end
    end

    def authorize!
      redirect(to('/login')) unless session[:user_id]
    end

  end

  get '/' do
    #authorize!
    @users = User.all
    @bookmarks = Bookmark.all
    @tags = Tag.all
    @taggings = Tagging.all
    File.read(File.join('public/views', 'index.html'))
  end

  set :protection => false

  with_tagList = {:methods => [:tagList]}


  get '/api/bookmarks' do
    @user = User.first(username: session[:username])

    #puts session[:username]

    #puts "user: " + @user.to_s

    @bookmarks = @user.bookmarks.all
    @bookmarks.to_json with_tagList
  end

  get '/api/bookmarks/:id' do
    @bookmark = Bookmark.get(params[:id])
    @bookmark.to_json with_tagList
  end

  put '/api/bookmarks/edit/:id' do
    # ...
    data = JSON.parse(request.body.read)
    input = data.slice "url", "title"
    if !input["url"].match(/^http/)
      input["url"] = "http://" + input["url"]
    end
    @bookmark = Bookmark.get(params[:id])
    if @bookmark.update! input
      add_tags(@bookmark,data)
      204 # No Content
    else
      400 # Bad Request
    end
  end

  delete '/api/bookmarks/:id' do
    # ...
    @bookmark = Bookmark.get(params[:id])
    if @bookmark.destroy
      200 # OK
    else
      500 # Internal Server Error
    end
  end


  post "/api/bookmarks" do
    @user = User.first(username: session[:username])
    data = JSON.parse(request.body.read)
    input = data.slice "url", "title"
    if !input["url"].match(/^http/)
      input["url"] = "http://" + input["url"]
    end

    bookmark = Bookmark.new  :user => @user
    bookmark.attributes = {:url => input["url"], :title => input["title"]}

    if  bookmark.save!
      # bookmark.save
      add_tags(bookmark,data)

      # Created
      [201, "/bookmarks/#{bookmark['id']}"]
    else
      400 # Bad Request
    end
  end


  post '/api/login' do
    data = JSON.parse(request.body.read)
    user = data.slice "userName", "password"

    @user = User.first(username: user["userName"])

    if @user.nil?
      [401,"The username you entered does not exist!"]
    elsif @user.authenticate(user["password"])

      session[:username] = user["userName"]
      #puts session[:username]
      token = SecureRandom.urlsafe_base64
      ret = {"access_token" => token, "userName" => user["userName"]}

      [200, ret.to_json]
    else
      [401,"Invalid username/password!"]
    end

  end

  post '/api/logout' do
    ret = {"access_token" => "", "userName" => ""}
    [200, ret.to_json]
  end





end

class Hash
  def slice(*whitelist)
    whitelist.inject({}) { |result, key| result.merge(key => self[key]) }
  end
end

