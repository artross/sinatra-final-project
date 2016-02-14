class DataGetterFromAPI
  @@base_url = "http://api.football-data.org/v1"

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
    JSON.load(open("#{@@base_url}/soccerseasons")).each_with_object([]) do |league, arr|
      arr << used_columns.each_with_object({}) do |column, hsh| 
      	hsh[column.underscore] = league[column] 
      end if supported_ids.include?(league["id"])
    end
  end
  
  def self.extract_team_id_from_url(team_url)
  	team_url.gsub("#{@@base_url}/teams/", "").to_i
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
  	JSON.load(open("#{@@base_url}/soccerseasons/#{league_id}/teams")).each_with_object([]) do |team, arr|
      arr << used_columns.each_with_object({}) do |column, hsh| 
      	if column == "id" then
          hsh[column] = self.extract_team_id_from_url(team["_links"]["self"])
      	else
      	  hsh[column.underscore] = team[column] 
      	end
      end 
    end
  end 

  def self.load_league_teams(league_id)
  	self.get_league_teams(league_id).each do |team|
  	# if !Team.find_by(name: team["name"]) then
  	#   newTeam = Team.create(team)
  	#   newTeam.leagues << League.find(league_id)
  	#   newTeam.save
  	# end
  end

  def self.load_leagues
  	self.get_supported_leagues.each do |league|
  	  # if !League.find(league["id"]) then
  	  #   League.create(league) !! league.year should be int and league.lastUpdated - datetime
  	  self.load_league_teams(league["id"])
  	  # end
  	end
  end

  def self.initialize_db
  	self.load_leagues
  end

end