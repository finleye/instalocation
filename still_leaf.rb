require "sinatra"
require "instagram"
require 'sinatra/partial'

class StillLeaf < Sinatra::Base
  register Sinatra::Partial
  enable :partial_underscores
  enable :sessions

  attr_accessor :insta_client
  set public_folder: "public", static: true

  get "/" do
    haml :welcome
  end

  get "/oauth/connect" do
    redirect Instagram.authorize_url(redirect_uri: ENV["INSTAGRAM_CALLBACK_URL"])
  end

  get "/oauth/callback" do
    response = Instagram.get_access_token(params[:code], redirect_uri: ENV["INSTAGRAM_CALLBACK_URL"])
    session[:ig_access_token] = response.access_token
    redirect "/nav"
  end

  get "/nav" do
    haml :nav
  end

  get "/user_recent_media" do
    @user = insta_client.user
    @recent_media = insta_client.user_recent_media

    haml :user_media
  end

  get '/media_like/:id' do
    insta_client.like_media("#{params[:id]}")
    redirect "/user_recent_media"
  end

  get '/media_unlike/:id' do
    insta_client.unlike_media("#{params[:id]}")
    redirect "/user_recent_media"
  end

  get "/user_media_feed" do
    user = insta_client.user
    html = "<h1>#{user.username}'s media feed</h1>"

    page_1 = insta_client.user_media_feed(777)
    page_2_max_id = page_1.pagination.next_max_id
    page_2 = insta_client.user_recent_media(777, :max_id => page_2_max_id ) unless page_2_max_id.nil?
    html << "<h2>Page 1</h2><br/>"
    for media_item in page_1
      html << "<img src='#{media_item.images.thumbnail.url}'>"
    end
    html << "<h2>Page 2</h2><br/>"
    for media_item in page_2
      html << "<img src='#{media_item.images.thumbnail.url}'>"
    end
    html
  end

  get "/location_recent_media" do
    html = "<h1>Media from the Instagram Office</h1>"
    for media_item in insta_client.location_recent_media(514276)
      html << "<img src='#{media_item.images.thumbnail.url}'>"
    end
    html
  end

  get "/media_search" do
    html = "<h1>Get a list of media close to a given latitude and longitude</h1>"
    for media_item in insta_client.media_search("37.7808851","-122.3948632")
      html << "<img src='#{media_item.images.thumbnail.url}'>"
    end
    html
  end

  get "/media_popular" do
    html = "<h1>Get a list of the overall most popular media items</h1>"
    for media_item in insta_client.media_popular
      html << "<img src='#{media_item.images.thumbnail.url}'>"
    end
    html
  end

  get "/user_search" do
    html = "<h1>Search for users on instagram, by name or usernames</h1>"
    for user in insta_client.user_search("instagram")
      html << "<li> <img src='#{user.profile_picture}'> #{user.username} #{user.full_name}</li>"
    end
    html
  end

  get "/location_search" do
    html = "<h1>Search for a location by lat/lng with a radius of 5000m</h1>"
    for location in insta_client.location_search("48.858844","2.294351","5000")
      html << "<li> #{location.name} <a href='https://www.google.com/maps/preview/@#{location.latitude},#{location.longitude},19z'>Map</a></li>"
    end
    html
  end

  get "/location_search_4square" do
    html = "<h1>Search for a location by Fousquare ID (v2)</h1>"
    for location in insta_client.location_search("3fd66200f964a520c5f11ee3")
      html << "<li> #{location.name} <a href='https://www.google.com/maps/preview/@#{location.latitude},#{location.longitude},19z'>Map</a></li>"
    end
    html
  end

  get "/tags" do
    html = "<h1>Search for tags, get tag info and get media by tag</h1>"
    tags = insta_client.tag_search('cat')
    html << "<h2>Tag Name = #{tags[0].name}. Media Count =  #{tags[0].media_count}. </h2><br/><br/>"
    for media_item in insta_client.tag_recent_media(tags[0].name)
      html << "<img src='#{media_item.images.thumbnail.url}'>"
    end
    html
  end

  get "/limits" do
    html = "<h1/>View API Rate Limit and calls remaining</h1>"
    response = insta_client.utils_raw_response
    html << "Rate Limit = #{response.headers[:x_ratelimit_limit]}.  <br/>Calls Remaining = #{response.headers[:x_ratelimit_remaining]}"

    html
  end

  def insta_client
    @insta_client = Instagram.client(access_token: session[:ig_access_token])
  end
end
