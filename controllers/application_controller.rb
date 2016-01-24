require 'still_leaf'
require 'haml'
require 'sinatra'
require 'instagram'
require 'sinatra/partial'
require 'rack-flash'

class ApplicationController < Sinatra::Base
  helpers ApplicationHelpers

  register Sinatra::Partial
  set :views, File.expand_path('../../views', __FILE__)
  enable :partial_underscores
  enable :sessions
  use Rack::Flash, sweep: true
  set public_folder: 'public'
end
