require 'sinatra'
require 'json'


class App < Sinatra::Base

  require_relative 'model/init'

  get '/hello' do
    "Hello World"
  end

  get '/' do
    send_file 'public/views/index.html'
  end

  before %r{/bookmarks/(\d+)} do |id|
    # ...
    @bookmark = Bookmark.get(id)

    if !@bookmark
      halt 404, "bookmark #{id} not found"
    end
  end

  with_tagList = {:methods => [:tagList]}

  get %r{/bookmarks/\d+} do
    content_type :json

    @bookmark.to_json with_tagList
  end

  put %r{/bookmarks/\d+} do
    # ...
    data = JSON.parse(request.body.read)
    input = data.slice "url", "title"
    if @bookmark.update! input
      add_tags(@bookmark,data)
      204 # No Content
    else
      400 # Bad Request
    end
  end

  delete %r{/bookmarks/\d+} do
    # ...
    if @bookmark.destroy
      200 # OK
    else
      500 # Internal Server Error
    end
  end

  get "/bookmarks/*" do
    tags = params[:splat].first.split "/"
    bookmarks = Bookmark.all
    tags.each do |tag|
      bookmarks = bookmarks.all({:taggings => {:tag => {:label => tag}}})
    end
    bookmarks.to_json with_tagList
  end

  def get_all_bookmarks
    Bookmark.all(:order => :title)
  end

  get "/bookmarks" do
    content_type :json
    get_all_bookmarks.to_json with_tagList
  end

  post "/bookmarks" do
    data = JSON.parse(request.body.read)
    input = data.slice "url", "title"

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

  helpers do
    def add_tags(bookmark,data)

      labels = (data["tagsAsString"] || "").split(",").map(&:strip)
      puts labels
      # more code to come

      existing_labels = []
      puts "Existing Lables: #{existing_labels}"
      bookmark.taggings.each do |tagging|
        puts "tagging: #{tagging}"
        if labels.include? tagging.tag.label
          existing_labels.push tagging.tag.label
        else
          tagging.destroy
        end
      end

      puts "Existing Lables 2: #{existing_labels}"

      (labels - existing_labels).each do |label|

        puts label
        tag = {:label => label}
        existing = Tag.first tag
        if !existing
          existing = Tag.create! tag
        end
        Tagging.create! :tag => existing, :bookmark => bookmark
      end
    end
  end



end



class Hash
  def slice(*whitelist)
    whitelist.inject({}) { |result, key| result.merge(key => self[key]) }
  end
end

