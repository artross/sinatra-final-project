class CreateTeams < ActiveRecord::Migration
  def change
  	create_table :teams do |t|
  	  t.string :name
  	  t.string :short_name
  	  t.string :crest_url
  	  t.timestamps
  	end
  end
end