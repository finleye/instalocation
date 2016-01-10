require 'rack-flash'

class StillLeaf < Sinatra::Base
  register Sinatra::Partial
  enable :partial_underscores
  enable :sessions
  use Rack::Flash, sweep: true

  attr_accessor :insta_client
  set public_folder: 'public'

  before do
    if request.path_info == '/' ||
        !session[:ig_access_token].nil? ||
        request.path_info =~ /\/oauth\//
      pass
    else
      redirect '/'
    end
  end

  get '/' do
    haml :welcome
  end

  get '/logout' do
    session.clear
    flash[:info] = "You have been logged out."
    redirect '/'
  end

  get '/oauth/connect' do
    scope =  'likes public_content'
    redirect Instagram.authorize_url(redirect_uri: ENV['INSTAGRAM_CALLBACK_URL'], scope: scope)
  end

  get '/oauth/callback' do
    response = Instagram.get_access_token(params[:code], redirect_uri: ENV['INSTAGRAM_CALLBACK_URL'])
    if response.access_token
      session[:ig_access_token] = response.access_token
      flash[:success] = "You've logged in as @#{insta_client.user.username}."
    else
      flash[:alert] = "Something went wrong."
    end

    redirect '/user_recent_media'
  end

  get '/nav' do
    haml :nav
  end

  get '/user_recent_media' do
    @user = insta_client.user
    @recent_media = insta_client.user_recent_media

    haml :user_media
  end

  get '/media_like/:id' do
    insta_client.like_media("#{params[:id]}")
    redirect '/user_recent_media'
  end

  get '/media_unlike/:id' do
    insta_client.unlike_media("#{params[:id]}")
    redirect '/user_recent_media'
  end

  get "/location_recent_media" do
    @media = insta_client.location_recent_media(514276)
    haml :location_recent_media
  end

  get "/media_search" do

    #@media = insta_client.media_search("48.8567", "2.3508", distance: 5000)
    if params[:lng] && params[:lat]
      @loc = [params[:lng], params[:lat]]
    elsif params[:query]
      @query = params[:query]
      opts = {address: @query}
      api = GmapsGeocoding::Api.new(opts)
      data = api.location
      @loc = api.finest_latlng(data['results']) if data.include?('status') && data['status'].eql?('OK')
    end

    @media = insta_client.media_search(@loc[1], @loc[0], distance: 5000) if @loc

    haml :media_search
  end

  def insta_client
    @insta_client = Instagram.client(access_token: session[:ig_access_token])
  end
end
