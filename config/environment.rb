ENV['SINATRA_ENV'] ||= "dev"

require 'bundler/setup'
Bundler.require(:default, ENV["SINATRA_ENV"])

ActiveRecord::Base.establish_connection(
	adapter: 'postgresql',
	database: "predictorium-#{ENV['SINATRA_ENV']}",
	username: 'postgres',
	password: ''
)

require 'json'
require 'open-uri'
require_all('app')