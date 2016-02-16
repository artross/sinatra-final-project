class CreateLeagues < ActiveRecord::Migration
  def change
  	create_table :leagues do |t|
  	  t.string :caption
  	  t.integer :year
  	  t.datetime :last_updated
  	  t.timestamps
  	end
  end
end