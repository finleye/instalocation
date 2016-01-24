class OauthController < ApplicationController
  get '/connect' do
    scope =  'likes public_content'
    callback_options = { redirect_uri: ENV['INSTAGRAM_CALLBACK_URL'], scope: scope }
    redirect Instagram.authorize_url(callback_options)
  end

  get '/callback' do
    response = Instagram.get_access_token(params[:code], redirect_uri: ENV['INSTAGRAM_CALLBACK_URL'])

    if response.access_token
      session[:ig_access_token] = response.access_token
      flash[:success] = "You've logged in as @#{insta_client.user.username}."
    else
      flash[:alert] = "Something went wrong."
    end

    redirect '/media/user'
  end
end
