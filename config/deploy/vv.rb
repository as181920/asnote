set :user, 'bbt'
set :repository,  "git@192.168.1.100:andersen/younoter.git"
server "192.168.1.100", :app, :web, :db, :primary => true
