# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

# We've told rails not to precompile anything in app/assets/stylesheets in
# config/initializers/propshaft_ignore_stylesheets.rb, because we're using
# yarn to build our stylesheets. In order to make this somewhat seamless, we
# can add a rake task that runs yarn build:all before running assets:precompile.
namespace :yarn do
  task :build_all, [ :env ] => :environment do
    puts 'Running yarn build:all...'
    system('yarn build:all') || abort('yarn build:all failed')
  end
end

Rake::Task['assets:precompile'].enhance([ 'yarn:build_all' ])
