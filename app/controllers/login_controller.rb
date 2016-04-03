class LoginController < ApplicationController

  get '/login' do
  	@login_failed = true if params[:login_failed]
    haml :'login/login.html'
  end

  post '/login' do
  	if params["submit"] == "Sign in" then
  	  user = User.find_by(name: params["login"], password: params["password"])
  	  if user then
  	  	session[:id] = user.id
  	  	redirect to('/index')
  	  else
  	  	redirect to('/login?login_failed=1')
  	  end
  	elsif params["submit"] == "Register" then
  	  redirect to('/register')
  	end
  end

  get '/register' do
    @reg_failed = true if params[:reg_failed]
    if @reg_failed then
      if params[:reg_failed] == "1" then
        @reg_fail_message = "Login can't be empty"
      elsif params[:reg_failed] == "2" then
        @reg_fail_message = "Password can't be empty"
      elsif params[:reg_failed] == "3" then
        @reg_fail_message = "Password isn't confirmed correctly" 
      end
    end   
  	haml :'login/register.html'
  end

  post '/register' do
    if params["submit"] == "Confirm" then
      if params["login"].strip == "" then
  	    redirect to('/register?reg_failed=1')
  	  elsif params["password"].strip == "" then
  	    redirect to('/register?reg_failed=2')
  	  elsif params["password"] != params["confirm"] then   
  	    redirect to('/register?reg_failed=3')
  	  else
  	    user = User.create!(name: params["login"], password: params["password"], prediction_points: 0)
  	    session[:id] = user.id	
  	    redirect to('/index')
  	  end 
    elsif params["submit"] == "Back" then
      redirect to('/login')
    end     
  end

  get '/logout' do
    session[:id] = nil
    redirect to('/login')
  end

end