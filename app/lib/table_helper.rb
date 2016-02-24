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
    query = <<-SQL
      SELECT
        f.id
        , f.date
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
        f.home_team_goals IS NULL
      ORDER BY
        f.date, f.id
    SQL
    
    conn.execute(query)
  end

  def self.results_with_filters(params)
    conn = ActiveRecord::Base.connection

    params[:days] = 7 if params[:days] <= 0
    date_condition_str = (Time.now - 60*60*24*params[:days]).strftime("%Y-%m-%d 00:00:00")
    
    query = <<-SQL
      SELECT
        f.date
        , home_t.short_name
        , away_t.short_name
        , f.home_team_goals
        , f.away_team_goals
        , p.home_team_goals
        , p.away_team_goals
        , p.prediction_points
      FROM
        predictions p
        INNER JOIN fixtures f ON p.fixture_id = f.id
        INNER JOIN teams home_t ON f.home_team_id = home_t.id
        INNER JOIN teams away_t ON f.away_team_id = away_t.id
      WHERE
        p.user_id = #{conn.quote(User.find_by(name: params[:username]).id)}
        AND f.date >= #{conn.quote(date_condition_str)}
        AND f.home_team_goals IS NOT NULL
    SQL

    if params[:league_id] > 0 then
      query += "AND f.league_id = #{conn.quote(params[:league_id])}"
    end  

    qres = ActiveRecord::Base.connection.execute(query)
  end
end