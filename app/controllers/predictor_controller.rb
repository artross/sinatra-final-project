class PredictorController < ApplicationController
  
  get '/' do
  	session[:login_failed] = false
  	session[:reg_failed] = false
  	session[:reg_fail_message] = ""
  	redirect to(logged_in? ? '/index' : '/login')
  end

  get '/index' do
  	@current_user ||= User.find_by(id: session[:id])
  	erb :'general/index.html'
  end

  get '/results/:user_id' do
  	@current_user ||= User.find_by(id: session[:id])
  	@selected_user ||= @current_user
  	erb :'general/results.html'
  end

  post '/results' do
    binding.pry
  	# get user_id, league and number of days from params[], then redirect to /results/:user_id 
  end

  get '/predictions' do
  	404 #erb :'predictions'
  end
  
  post '/predictions' do
    404
  end	

  def logged_in?
  	session[:id] && User.find_by(id: session[:id])
  end

end