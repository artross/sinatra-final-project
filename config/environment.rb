ENV['SINATRA_ENV'] ||= "development"

require 'bundler/setup'
Bundler.require(:default, ENV["SINATRA_ENV"])

ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])

require 'json'
require 'open-uri'
require_all('app')