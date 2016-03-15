class DataGetterFromAPI
  ##### CONSTANTS
  @@base_url = "http://api.football-data.org/v1"
  @@token = "dca072f3d0c4423dbc794490830c472f"
  ########################
  ##### GET DATA FROM API
  ########################

  def self.get_supported_leagues
    # returns an array of hashes: {
    #   _links: hash (with query links to self, teams, fixtures and league table),
    #   id: int,
    #   caption: str,
    #   league: str (string league ID),
    #   year: str (starting year, "2015"),
    #   currentMatchday: int,
    #   numberOfMatchdays: int,
    #   numberOfTeams: int,
    #   numberOfGames: int,
    #   lastUpdated: str ("2016-02-14T16:56:44Z")
    # }
    # here we need {id, caption, year, lastUpdated}
    # for now supported leagues will be:
    # - English Premier League (id )
    # - Deutch Bundesliga
    # - Italian Serie A
    # - Spanish Primera 
    # their id's for season 2015/16 respectively are: 398, 394, 401, 399

    supported_ids = [394, 398, 399, 401]
    used_columns = ["id", "caption", "year", "lastUpdated"]
    JSON.load(open("#{@@base_url}/soccerseasons", "X-Auth-Token" => "#{@@token}")).each_with_object([]) do |league, arr|
      arr << used_columns.each_with_object({}) do |column, hsh| 
      	if column == "year" then
      	  hsh[column] = league[column].to_i
      	elsif column == "lastUpdated" then
      	  hsh[column.underscore] = DateTime.strptime(league[column], '%Y-%m-%dT%H:%M:%S%z')
      	else    
      	  hsh[column.underscore] = league[column] 
      	end
      end if supported_ids.include?(league["id"])
    end
  end
  
  def self.get_league_teams(league_id)
  	# returns a hash in which we need "teams" record, which is an array of hashes:
  	# {
    #   _links: hash (with query links to self, fixtures and players),
  	#   code: str (kind of string ID, can be null!!!),
  	#   name: str ("RC Deportivo La Coruna"),
  	#   shortName: str ("La Coruna"),
  	#   squadMarketValue: str ("53,950,000 €"),
  	#   crestUrl: str (link to a logo, "http://upload.wikimedia.org/wikipedia/en/4/4e/RC_Deportivo_La_Coruña_logo.svg")
  	# }
  	# here we need {name, shortName, crestUrl}
  	# also team ID will be extracted from _links["self"]

    used_columns = ["id", "name", "shortName", "crestUrl"]
  	JSON.load(open("#{@@base_url}/soccerseasons/#{league_id}/teams", "X-Auth-Token" => "#{@@token}"))["teams"].each_with_object([]) do |team, arr|
      arr << used_columns.each_with_object({}) do |column, hsh| 
      	if column == "id" then
          hsh[column] = self.extract_team_id_from_url(team["_links"]["self"]["href"])
      	else
      	  hsh[column.underscore] = team[column] 
      	end
      end 
    end
  end 

  def self.get_league_fixtures(league_id, timeframe)
  	# returns a hash in which we need "fixtures" record, which is an array of hashes:
  	# {
    #   _links: hash (with query links to self, league, home and away teams),
  	#   matchday: int,
  	#   date: str ("2016-02-20T14:30:00Z"),
  	#   status: str,
  	#   homeTeamName: str,
  	#   awayTeamName: str,
  	#   result: hash { goalsHomeTeam: int, goalsAwayTeam: int} (both nulls if not played yet)
  	# }
  	# here we need {matchday, date, status, result["goalsHomeTeam"], result["goalsAwayTeam"]}
  	# also ID will be extracted from _links["self"]
  	#   and team IDs - from _links["homeTeam"] and _links["awayTeam"]

    used_columns = ["id", "matchday", "date", "homeTeamID", "awayTeamID", "status", "goalsHomeTeam", "goalsAwayTeam"]
  	JSON.load(open("#{@@base_url}/soccerseasons/#{league_id}/fixtures?timeFrame=#{timeframe}", "X-Auth-Token" => "#{@@token}"))["fixtures"].each_with_object([]) do |fixture, arr|
      arr << used_columns.each_with_object({}) do |column, hsh| 
      	if column == "id" then
          hsh[column] = self.extract_fixture_id_from_url(fixture["_links"]["self"]["href"])
      	elsif column == "date" then
      	  hsh[column] = DateTime.strptime(fixture[column], '%Y-%m-%dT%H:%M:%S%z')
      	elsif column == "homeTeamID" or column == "awayTeamID" then
          hsh[column.underscore] = self.extract_team_id_from_url(fixture["_links"]["#{column[0..-3]}"]["href"])
        elsif column == "goalsHomeTeam" then
          hsh["home_team_goals"] = fixture["result"][column]  
        elsif column == "goalsAwayTeam" then
          hsh["away_team_goals"] = fixture["result"][column]  
      	else
      	  hsh[column.underscore] = fixture[column] 
      	end
      end 
    end
  end

  ########################
  ##### TOP LEVEL METHODS
  ########################

  def self.initialize_db
  	self.load_leagues
  	self.load_teams
  end

  def self.load_fixtures
    self.load_scheduled_games
    self.load_results
  end

  ########################
  ##### LEVEL 1 METHODS
  ########################

  def self.load_leagues
  	self.get_supported_leagues.each do |league|
  	  League.create(league) unless League.find_by(id: league["id"])
  	end
  end

  def self.load_teams
  	self.get_supported_leagues.each do |league|
      self.load_league_teams(league["id"]) if League.find_by(id: league["id"])
    end
  end

  def self.load_scheduled_games
  	puts "#{Time.now}: starting 'Scheduled games'"
    self.get_supported_leagues.each do |league|
  	  res = self.load_league_scheduled_games(league["id"])
  	  puts "#{league["caption"]}: #{res}"
  	end
    puts "#{Time.now}: completed"
    puts "----------"
  end

  def self.load_results
    puts "#{Time.now}: starting 'Results'"
  	self.get_supported_leagues.each do |league|
  	  res, pred = self.load_league_results_update_predictions(league["id"])
  	  puts "#{league["caption"]}: #{res} (#{pred})"
  	end
    puts "#{Time.now}: completed"
    puts "----------"
  end

  ########################
  ##### LEVEL 2 METHODS
  ########################

  def self.load_league_teams(league_id)
  	self.get_league_teams(league_id).each do |team|
  	  unless Team.find_by(id: team["id"]) then
  	    new_team = Team.new(team)
  	    new_team.leagues << League.find(league_id)
  	    new_team.save
  	  end
    end
  end

  def self.load_league_scheduled_games(league_id)
    fixtures_loaded = 0
  	self.get_league_fixtures(league_id, "n14").each do |fixture|
  	  unless Fixture.find_by(id: fixture["id"]) then
  	  	new_fixture = Fixture.new(fixture)
  	  	new_fixture.league = League.find_by(id: league_id)
  	  	new_fixture.save
  	  	fixtures_loaded += 1
  	  end
  	end
  	fixtures_loaded
  end

  def self.load_league_results_update_predictions(league_id)
    results_loaded = 0
    predictions_updated = 0
  	self.get_league_fixtures(league_id, "p3").each do |fixture|
  	  f = Fixture.find_by(id: fixture["id"])
      if fixture["home_team_goals"] && !f.home_team_goals then
  	  	f.home_team_goals = fixture["home_team_goals"]
  	  	f.away_team_goals = fixture["away_team_goals"]
  	  	f.status = fixture["status"]
  	  	f.save
  	  	results_loaded += 1
        predictions_updated += self.update_predictions_by_fixture(f.id)
  	  end
  	end
  	[results_loaded, predictions_updated]
  end

  ########################
  ##### LEVEL 3 METHODS
  ########################

  def self.update_predictions_by_fixture(fixture_id)
    predictions_updated = 0
    f = Fixture.find_by(id: fixture_id)
    f_diff = f.home_team_goals - f.away_team_goals
    Prediction.where(fixture_id: fixture_id).each do |p|
      p_diff = p.home_team_goals - p.away_team_goals
      if f_diff == p_diff then
        p.prediction_points = f.home_team_goals == p.home_team_goals ? 3 : 2
      else
        p.prediction_points = f_diff * p_diff > 0 ? 1 : 0
      end
      p.save
      predictions_updated += 1
      
      if p.prediction_points > 0 then 
        u = User.find_by(id: p.user_id)
        u.prediction_points += p.prediction_points
        u.save
      end    
    end
    predictions_updated
  end

  ########################
  ##### SERVICE METHODS
  ########################

  def self.extract_team_id_from_url(url)
  	url.gsub("#{@@base_url}/teams/", "").to_i
  end

  def self.extract_fixture_id_from_url(url)
  	url.gsub("#{@@base_url}/fixtures/", "").to_i
  end

end