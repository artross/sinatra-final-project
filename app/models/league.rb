class League < ActiveRecord::Base
  has_and_belongs_to_many :teams
  has_many :fixtures

  def self.active_leagues
  	current_year = Time.now.year
    arr = self.where("year = ?", current_year.to_s).order(:id)
    arr = self.where("year = ?", (current_year - 1).to_s).order(:id) if arr == nil || arr.size == 0
  end

end