class PredictorController < ApplicationController
  
  get '/' do
  	session[:login_failed] = false
  	redirect to(logged_in? ? '/index' : '/login')
  end

  get '/index' do
  	"Welcome!"
  end

  def logged_in?
  	session[:id] && User.find_by(id: session[:id])
  end

end