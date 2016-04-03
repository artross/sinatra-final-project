class PredictorController < ApplicationController
  
  get '/' do
  	redirect to(logged_in? ? '/index' : '/login')
  end

  get '/index' do
    redirect to('/login') unless logged_in?

  	@current_user = User.find_by(id: session[:id])
  	@current_users_place = User.find_place_by_id(session[:id])
  	@all_predictors = User.all_predictors
  	haml :'general/index.html'
  end

  get '/results/:user_id' do
    redirect to('/login') unless logged_in?
    
  	@current_user = User.find_by(id: session[:id])
  	@selected_user = User.find_by(id: params[:user_id])
  	@days = params[:days] == nil ? 7 : params[:days]
  	@not_found = true if params[:not_found]
    @username_not_found = params[:username] if @not_found
    @active_leagues = League.active_leagues
  	@results = DataMiner.results_with_filters({days: @days, user_id: @selected_user.id})
  	haml :'general/results.html'
  end

  post '/results' do
  	@current_user = User.find_by(id: session[:id])
  	@selected_user = User.find_by(name: params[:username])
    if @selected_user == nil then
  	  redirect to("/results/#{@current_user.id}?not_found=1&username=#{params[:username]}")
  	else
  	  redirect to("/results/#{@selected_user.id}?days=#{params[:days]}&league_id=#{params[:league_id]}") 
  	end
  end

  get '/predictions' do
    redirect to('/login') unless logged_in?
    
  	@current_user = User.find_by(id: session[:id])
    @active_leagues = League.active_leagues
  	@fixtures_to_predict = DataMiner.fixtures_to_predict(session[:id])
    haml :'general/predictions.html'
  end
  
  post '/predictions' do
    params[:predictions].each do |p|
      unless fixture_expired?(p[:id].to_i) || p[:home] == "" || p[:away] == "" then
      	prediction = Prediction.find_by(fixture_id: p[:id].to_i, user_id: session[:id])
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
      	  	  fixture_id: p[:id].to_i, 
      	  	  home_team_goals: p[:home].to_i, 
      	  	  away_team_goals: p[:away].to_i, 
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

  def fixture_expired?(fixture_id)
    Fixture.find(fixture_id).date < Time.now + 60*60
  end
end