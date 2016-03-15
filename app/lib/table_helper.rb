class TableHelper
  def self.all_predictors
  	# all users whos prediction_points are positive
  	User.select("id, name, prediction_points")
  	    .where("prediction_points > 0")
  	    .order("prediction_points desc, name")
  end

  def self.find_place_by_id(user_id)
  	collection = self.all_predictors
  	collection.each_with_index do |e, i|
  	  return (i + 1) if e.id == user_id
  	end 
  	
  	return collection.size + 1
  end
  
  def self.fixtures_to_predict(user_id)
    conn = ActiveRecord::Base.connection
    deadline = (Time.now + 60*60).strftime("%Y-%m-%d %H:%M:%S")
    query = <<-SQL
      SELECT
        f.id
        , f.date
        , f.league_id
        , home_t.short_name home_team
        , away_t.short_name away_team
        , p.home_team_goals
        , p.away_team_goals
      FROM
        fixtures f 
        INNER JOIN teams home_t ON f.home_team_id = home_t.id
        INNER JOIN teams away_t ON f.away_team_id = away_t.id
        LEFT OUTER JOIN predictions p ON f.id = p.fixture_id AND p.user_id = #{conn.quote(user_id)}
      WHERE
        f.date > #{conn.quote(deadline)}
      ORDER BY
        f.league_id, f.date, f.id
    SQL
    
    conn.execute(query)
  end

  def self.results_with_filters(params)
    conn = ActiveRecord::Base.connection

    if params[:days] == nil then
      days = 7
    else
      days = params[:days].to_i
      days = 7 if days <= 0
    end

    date_condition_str = (Time.now - 60*60*24*days).strftime("%Y-%m-%d 00:00:00")
    
    query = <<-SQL
      SELECT
        f.date
        , f.league_id
        , home_t.short_name home_team
        , away_t.short_name away_team
        , f.home_team_goals home_team_goals
        , f.away_team_goals away_team_goals
        , p.home_team_goals home_team_pred
        , p.away_team_goals away_team_pred
        , p.prediction_points points
      FROM
        predictions p
        INNER JOIN fixtures f ON p.fixture_id = f.id
        INNER JOIN teams home_t ON f.home_team_id = home_t.id
        INNER JOIN teams away_t ON f.away_team_id = away_t.id
      WHERE
        p.user_id = #{conn.quote(params[:user_id])}
        AND f.date >= #{conn.quote(date_condition_str)}
        AND f.home_team_goals IS NOT NULL
    SQL

    qres = ActiveRecord::Base.connection.execute(query)
  end
end