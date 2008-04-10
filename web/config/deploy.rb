set :application, "radia-source"
set :repository,  "http://radia-source.googlecode.com/svn/trunk"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:

set :deploy_to, "/usr/local/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "http://source.radiozero.pt"
role :web, "http://source.radiozero.pt"
role :db,  "http://source.radiozero.pt", :primary => true