class StaticPagesController < ApplicationController
  get '/' do
    haml :welcome
  end

  get '/logout' do
    session.clear
    flash[:info] = "You have been logged out."
    redirect '/'
  end
end
