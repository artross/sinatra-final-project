class CreateLeaguesTeams < ActiveRecord::Migration
  def change
  	create_join_table :leagues, :teams
  end
end