# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, "./log/#{Time.now.strftime("%Y-%m-%d")}.log"

# every 30.minutes do
#   rake "load_from_api:results"
# end

# every 1.day, :at => '11:15 am' do
#   rake "load_from_api:scheduled_games"
# end

every 1.hour do
  rake "heroku:do_all"
end	

every 1.day, :at => '00:01 am' do
  rake "whenever:update_jobs"
end