class Team < ActiveRecord::Base
  has_and_belongs_to_many :leagues

  def fixtures(league_id, match_day = -1)
  	return nil unless league_id

  	if match_day == -1 then
  	  sql = "
  	    SELECT * 
  	    FROM fixtures 
  	    WHERE 
  	      league_id = ? 
  	      AND (home_team_id = ? 
  	      	OR away_team_id = ?)"
  	  self.connection.exec_query(sql, [league_id, id, id])
  	else
  	  fixture = Fixture.find_by(league_id: league_id, matchday: matchday, home_team_id: id)
  	  fixture ||= Fixture.find_by(league_id: league_id, matchday: matchday, away_team_id: id)
  	  [fixture]  
  	end
  end
end