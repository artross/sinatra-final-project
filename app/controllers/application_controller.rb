class ApplicationController < Sinatra::Base

  set :views, File.expand_path('../views', __FILE__)

  enable :sessions, :method_override
  set :session_secret, "mex"

  register Sinatra::ActiveRecordExtension
  
end