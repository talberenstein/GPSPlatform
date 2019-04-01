set :stage, :production
set :rails_env, "production"
set :branch, "master"

server '162.248.55.181', user: 'deploy', port: 22, roles: %w{web app db}
