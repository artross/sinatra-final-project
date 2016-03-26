require './config/environment'

if defined?(ActiveRecord::Migrator) && ActiveRecord::Migrator.needs_migration?
  raise 'Migrations are pending run `rake db:migrate` to resolve the issue.'
end

set :database, ENV['DATABASE_URL'] || "postgres://localhost/predictorium-#{ENV['SINATRA_ENV']}"

use Rack::MethodOverride
use Rack::Static, :root => 'public', :urls => ["/images","/javascripts","/stylesheets"]
use LoginController
use PredictorController
run ApplicationController