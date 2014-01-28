load 'deploy'

require 'hipchat/capistrano'

set :stages, %w(demo staging production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :user, 'utah'
set :application, 'flyingdog'
# domain is set in config/deploy/{stage}.rb

# file paths
set :repository, "git@github.com:utahstreetlabs/#{application}.git"
set(:deploy_to) { "/home/#{user}/#{application}" }

# one server plays all roles
role :app do
  fetch(:domain)
end

set :deploy_via, :remote_cache
set :scm, 'git'
set :scm_verbose, true
set(:branch) do
  case stage
  when "production" then "production"
  else "staging"
  end
end
set :use_sudo, false

after "deploy", "deploy:cleanup"

namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do
    run "#{sudo} start #{application}"
  end

  task :stop, :roles => :app, :except => { :no_release => true } do
    run "#{sudo} stop #{application}"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    start
  end
end
