
class StillLeaf < Sinatra::Base
  register Sinatra::Partial
  enable :partial_underscores
  enable :sessions

  attr_accessor :insta_client
  set public_folder: 'public', static: true

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
    redirect '/'
  end

  get '/oauth/connect' do
    scope =  'likes public_content'
    redirect Instagram.authorize_url(redirect_uri: ENV['INSTAGRAM_CALLBACK_URL'], scope: scope)
  end

  get '/oauth/callback' do
    response = Instagram.get_access_token(params[:code], redirect_uri: ENV['INSTAGRAM_CALLBACK_URL'])
    session[:ig_access_token] = response.access_token
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
    @lng = params[:lng]
    @lat = params[:lat]
    if !@lng.nil? && !@lat.nil?
      @media = insta_client.media_search(@lng, @lat, distance: 5000)
    end

    haml :media_search
  end

  def insta_client
    @insta_client = Instagram.client(access_token: session[:ig_access_token])
  end
end
