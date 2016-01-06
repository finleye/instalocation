require_relative "spec_helper"
require_relative "../insta_location.rb"

def app
  InstaLocation
end

describe InstaLocation do
  it "responds with a welcome message" do
    get '/'

    last_response.body.must_include 'Welcome to the Sinatra Template!'
  end
end
