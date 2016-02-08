require 'json'
require 'open-uri'

class TestAPI
  @@base_url = "http://api.football-data.org/v1"

  def get_leagues
    JSON.load(open("#{@@base_url}/soccerseasons"))
  end
end

tester = TestAPI.new