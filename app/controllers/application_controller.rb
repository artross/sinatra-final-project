class ApplicationController < Sinatra::Base

  set :views, Proc.new { File.join(root, "../views") }

  enable :sessions, :method_override
  set :session_secret, "mex"

  register Sinatra::ActiveRecordExtension

end