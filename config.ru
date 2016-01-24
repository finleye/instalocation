
# Load path and gems/bundler
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))
require 'bundler'
Bundler.require

if ENV['RACK_ENV'] != 'production'
  require 'pry'
  require 'dotenv'
  Dotenv.load
end


# Local config
require 'find'

%w{config/initializers lib helpers controllers}.each do |load_path|
  Find.find(load_path) { |f|
    require f unless f.match(/\/\..+$/) || File.directory?(f)
  }
end

#run StillLeaf
map('/media') { run MediaController }
map('/oauth') { run OauthController }
map('/') {run StaticPagesController }

