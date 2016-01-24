class MediaController < ApplicationController
  before { authenticate! }

  get '/nav' do
    haml :nav
  end

  get '/user' do
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

  get "/search" do
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
end
