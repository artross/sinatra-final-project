class User < ActiveRecord::Base
  has_many :predictions
  
  def self.all_predictors
  	# all users whos prediction_points are positive
  	self.select("id, name, prediction_points")
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
end