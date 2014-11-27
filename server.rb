require 'sinatra'
require 'json'
require 'digest/md5'


class Server < Sinatra::Base

  use Rack::Session::Pool, :expire_after  => 120

  require_relative 'model/init'

  before do
    headers 'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST'],
            'Access-Control-Allow-Headers' => 'Content-Type'
  end

  configure do
    enable :sessions
    set :usernameMD5, '9661fd65249b026ebea0f49927e82f0e'
    set :passwordMD5, 'b9556622dad3756764860385651e95ae'
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
    @bookmarks = Bookmark.all
    @tags = Tag.all
    @taggings = Tagging.all
    File.read(File.join('public/views', 'index.html'))
  end

  set :protection => false

  with_tagList = {:methods => [:tagList]}


  get '/bookmarks' do
    @bookmarks = Bookmark.all
    @bookmarks.to_json with_tagList
  end

  get '/bookmarks/:id' do
    @bookmark = Bookmark.get(params[:id])
    @bookmark.to_json with_tagList
  end

  put '/bookmarks/edit/:id' do
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

  delete '/bookmarks/:id' do
    # ...
    @bookmark = Bookmark.get(params[:id])
    if @bookmark.destroy
      200 # OK
    else
      500 # Internal Server Error
    end
  end


  post "/bookmarks" do
    data = JSON.parse(request.body.read)
    input = data.slice "url", "title"
    if !input["url"].match(/^http/)
      input["url"] = "http://" + input["url"]
    end

    bookmark = Bookmark.new input

    if  bookmark.save!
      # bookmark.save
      add_tags(bookmark,data)

      # Created
      [201, "/bookmarks/#{bookmark['id']}"]
    else
      400 # Bad Request
    end
  end


  post '/login' do
    data = JSON.parse(request.body.read)
    user = data.slice "userName", "password"

    if Digest::MD5.hexdigest(user["userName"]).eql?(settings.usernameMD5) && Digest::MD5.hexdigest(user["password"]).eql?(settings.passwordMD5)
      token = SecureRandom.urlsafe_base64
      ret = {"access_token" => token, "userName" => user["userName"]}

      [200, ret.to_json]
    else
      [401,"Invalid username/password!"]
    end

  end

  post '/logout' do
    ret = {"access_token" => "", "userName" => ""}
    [200, ret.to_json]
  end

=begin
  app.post('/api/logout', requiresAuthentication, function(request, response) {
                          var token= request.headers.access_token;
                          removeFromTokens(token);
                          response.send(200);
                        });
=end


=begin
  post('/api/login', function(request, response) {
                     var userName = request.body.userName;
                     var password = request.body.password;

                     if (userName === "Ravi" && password === "kiran") {
                         var expires = new Date();
                     expires.setDate((new Date()).getDate() + 5);
                     var token = jwt.encode({
                                                userName: userName,
                                                expires: expires
                                            }, app.get('jwtTokenSecret'));

                     tokens.push(token);

                     response.send(200, { access_token: token, userName: userName });
                     } else {
                         response.send(401, "Invalid credentials");
                     }
=end




end

class Hash
  def slice(*whitelist)
    whitelist.inject({}) { |result, key| result.merge(key => self[key]) }
  end
end

