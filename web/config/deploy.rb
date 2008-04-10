require 'mongrel_cluster/recipes'

set :application, "radia-source"
set :repository,  "http://radia-source.googlecode.com/svn/trunk/web"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:

set :deploy_to, "/usr/local/var/#{application}"
set :deploy_via, :export
set :user, 'tecnica'
set :runner, 'tecnica'
set :use_sudo, false

set :mongrel_conf, "#{shared_path}/config/mongrel_cluster.yml"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "source.radiozero.pt"
role :web, "source.radiozero.pt"
role :db,  "source.radiozero.pt", :primary => true

namespace :deploy do

  desc "Use a different production password"
  task :move_db_config, :roles => :app do
    db_config = "#{shared_path}/config/database.yml.production"
    run "cp #{db_config} #{release_path}/config/database.yml" 
  end
  
  task :move_spin_script, :roles => :app do
    run "cp #{shared_path}/script/spin.example #{current_path}/script/spin"
  end
  
end


after "deploy:update_code", "deploy:move_db_config"
after "deploy:move_db_config", "deploy:move_spin_script"