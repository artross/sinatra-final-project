class LoginController < ApplicationController

  get '/login' do
  	erb :'login/login.html'
  end

  post '/login' do
  	if params["submit"] == "Login" then
  	  user = User.find_by(name: params["login"], password: params["password"])
  	  session[:login_failed] = (user == nil)
  	  if user then
  	  	session[:id] = user.id
  	  	redirect to('/index')
  	  else
  	  	redirect to('/login')
  	  end
  	else
  	  redirect to('/register')
  	end
  end

  get '/register' do
  	erb :'login/register.html'
  end

  post '/register' do
  	404
  	# set session[:login_failed] to false
  end

end