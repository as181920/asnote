require "bundler/capistrano"

set :rvm_ruby_string ,  'ruby-1.9.3-p286@younoter' #这个值是你要用rvm的gemset。名字要和系统里有的要一样。
set :rvm_type ,  :user   # Don't use system-wide RVM
require 'rvm/capistrano'

set :stages, %w(vv production)
set :default_stage, "production"
require 'capistrano/ext/multistage'


set :application, "younoter"

# set :scm, :subversion
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :scm, :git
set :scm_username, 'git'

set :branch, "master"
set :user, 'andersen'
set :use_sudo, false
set :deploy_via, :remote_cache
set :deploy_to, "/home/#{user}/deployments/#{application}"
set :deploy_env, 'production'
set :rails_env, "production"
#role :web, "your web-server here"                          # Your HTTP server, Apache/etc
#role :app, "your app-server here"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:

set :keep_releases, 15
after "deploy:restart", "deploy:cleanup"
# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :backup do
  task :local do
    run "mongodump -d asnote_production -o ~/backup/dump"
  end
  task :bbtang do
    run "mongodump -d asnote_production -o ~/backup/dump && tar cjvf ~/backup/mongodump.tar.bz2 ~/backup/dump && scp -v ~/backup/mongodump.tar.bz2 andersen@bbtang.com:~/"
  end
end

task :status do
  run "uname -a"
  run "df -h|grep mapper"
  run "free -ml|grep  ^[^H,^L]"
  run "sensors|head -n4|grep ^temp"
  run "top -b -n 1|head -n 5"
  #run "ps aux|grep -iE 'java|ruby|rack|mongo'"
end
