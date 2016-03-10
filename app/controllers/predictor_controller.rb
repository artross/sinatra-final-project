class PredictorController < ApplicationController
  
  get '/' do
  	redirect to(logged_in? ? '/index' : '/login')
  end

  get '/index' do
  	@current_user = User.find_by(id: session[:id])
  	@current_users_place = TableHelper.find_place_by_id(session[:id])
  	@all_predictors = TableHelper.all_predictors
  	erb :'general/index.html'
  end

  get '/results/:user_id' do
  	@current_user = User.find_by(id: session[:id])
  	@selected_user = User.find_by(id: params[:user_id])
  	@days = params[:days] == nil ? 7 : params[:days]
  	@league_id = params[:league_id] == nil ? -1 : params[:league_id]
  	@not_found = true if params[:not_found]
  	@results = TableHelper.results_with_filters({days: @days, league_id: params[:league_id], user_id: @selected_user.id})
  	erb :'general/results.html'
  end

  post '/results' do
  	@current_user = User.find_by(id: session[:id])
  	@selected_user = User.find_by(name: params[:username])
  	if @selected_user == nil then
  	  redirect to("/results/#{@current_user.id}?not_found=1")
  	else
  	  redirect to("/results/#{@selected_user.id}?days=#{params[:days]}&league_id=#{params[:league_id]}") 
  	end
  end

  get '/predictions' do
  	@current_user = User.find_by(id: session[:id])
  	@fixtures_to_predict = TableHelper.fixtures_to_predict(session[:id])
    erb :'general/predictions.html'
  end
  
  post '/predictions' do
    params[:predictions].each do |p|
      unless p[:home] == "" || p[:away] == "" then
      	prediction = Prediction.find_by(fixture_id: p[:id], user_id: session[:id])
      	if prediction then
      	  unless prediction.home_team_goals == p[:home].to_i && prediction.away_team_goals == p[:away].to_i then
      	    prediction.home_team_goals = p[:home].to_i
      	    prediction.away_team_goals = p[:away].to_i
      	    prediction.save
      	  end  
      	else
      	  Prediction.create(
      	  	{
      	  	  user_id: session[:id], 
      	  	  fixture_id: p[:id], 
      	  	  home_team_goals: p[:home], 
      	  	  away_team_goals: p[:away], 
      	  	  prediction_points: 0
      	  	})
      	end  	  
      end
    end
    redirect to('/predictions')
  end	

  def logged_in?
  	session[:id] && User.find_by(id: session[:id])
  end

  def supported_leagues
  	current_year = Time.now.year
    arr = League.where("year = ?", current_year.to_s)
    arr = League.where("year = ?", (current_year - 1).to_s) if arr.size == 0
  end

end