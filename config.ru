if defined?(ActiveRecord::Migrator) && ActiveRecord::Migrator.needs_migration?
  raise 'Migrations are pending run `rake db:migrate` to resolve the issue.'
end

use Rack::MethodOverride
use Rack::Static, :root => 'public', :urls => ['/images', '/stylesheets']
# use MyControllers
run ApplicationController