require_relative './config/environment'
require 'sinatra/activerecord/rake'

desc "Starts a Pry console with all the environment loaded"
task :console do
  Pry.start
end

namespace :load_from_api do
  desc "Populates DB with supported leagues based on the data from API"
  task :leagues do
    DataGetterFromAPI.load_leagues
  end

  desc "Populates DB with teams from supported leagues based on the data from API"
  task :teams do
    DataGetterFromAPI.load_teams
  end

  desc "Populates DB with newly scheduled games within 14 days"
  task :scheduled_games do
  	DataGetterFromAPI.load_scheduled_games
  end

  desc "Updates DB with results for the games scheduled in the past 3 days"
  task :results do
  	DataGetterFromAPI.load_results
  end
end

namespace :whenever do
  desc "updating 'whenever' output settings"
  task :update_jobs do
    sh %{bundle exec whenever --update-crontab FootballPredictions}
  end
end

namespace :heroku
  desc "one task to rule'em all"
  task :do_all do
    1
  end
end