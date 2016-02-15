class Team < ActiveRecord::Base
  has_and_belongs_to_many :leagues

  def get_fixtures(league_id, match_day = -1)
  	return null if !league_id

  	if match_day == -1 then
  	  SQL = "
  	    SELECT * 
  	    FROM fixtures 
  	    WHERE 
  	      league_id = ? 
  	      AND (home_team_id = ? 
  	      	OR away_team_id = ?)"
  	  self.connection.exec_query(SQL,,[league_id, id, id])
  	else
  	  fixture = Fixture.find_by(league_id: league_id, match_day: match_day, home_team_id: id)
  	  fixture ||= Fixture.find_by(league_id: league_id, match_day: match_day, away_team_id: id)
  	  [fixture]  
  	end
  end
end