set :user, 'bbt'
set :deploy_to, "/home/#{user}/deployments/#{application}"
set :rails_env, "production"
set :repository,  "git@192.168.1.100:andersen/younoter.git"
server "192.168.1.100", :app, :web, :db, :primary => true
