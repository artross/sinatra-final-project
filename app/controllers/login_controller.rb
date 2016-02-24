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
  	if params["login"].strip == "" then
  	  session[:reg_failed] = true
  	  session[:reg_fail_message] = "Login can't be empty"
  	  redirect to('/register')
  	elsif params["password"].strip == "" then
  	  session[:reg_failed] = true
  	  session[:reg_fail_message] = "Password can't be empty"
  	  redirect to('/register')
  	elsif params["password"] != params["confirm"] then   
  	  session[:reg_failed] = true
  	  session[:reg_fail_message] = "Password isn't confirmed correctly"
  	  redirect to('/register')
  	else
  	  user = User.create!(name: params["login"], password: params["password"], prediction_points: 0)
  	  session[:id] = user.id	
  	  session[:reg_failed] = false
  	  session[:reg_fail_message] = ""
  	  session[:login_failed] = false
  	  redirect to('/index')
  	end  
  end

  get '/logout' do
    session[:id] = nil
    redirect to('/login')
  end

end