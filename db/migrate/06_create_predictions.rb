class CreatePredictions < ActiveRecord::Migration
  def change
  	create_table :predictions do |t|
  	  t.integer :user_id
  	  t.integer :fixture_id
  	  t.integer :home_team_goals
  	  t.integer :away_team_goals
  	  t.integer :prediction_points
  	  t.timestamps

  	  t.index :user_id
  	  t.index :fixture_id
  	end
  end
end