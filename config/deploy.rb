# config valid only for current version of Capistrano
lock '3.7.1'

set :application, 'gps.gestsol.cl'
set :repo_url, 'git@github.com:gestsol/gps-web.git'
set :deploy_to, "/opt/#{fetch(:stage)}/gps-web"
set :keep_releases, 3
set :passenger_restart_command, 'touch'
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/application.yml', 'config/endpoints.yml')
set :passenger_restart_options, -> { "#{deploy_to}/current/tmp/restart.txt" }

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :mkdir, '-p', "#{ release_path }/tmp"
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end
  after :publishing, 'deploy:restart'
  after :finishing, 'deploy:cleanup'
end
