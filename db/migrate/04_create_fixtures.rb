class CreateFixtures < ActiveRecord::Migration
  def change
  	create_table :fixtures do |t|
  	  t.integer :league_id
  	  t.integer :matchday
  	  t.datetime :date
  	  t.integer :home_team_id
  	  t.integer :away_team_id
  	  t.string :status
  	  t.integer :home_team_goals
  	  t.integer :away_team_goals
  	  t.timestamps

  	  t.index :league_id
  	  t.index :home_team_id
  	  t.index :away_team_id
  	end
  end
end