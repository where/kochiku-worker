require "rvm/capistrano"
set :rvm_type, :user
set :rvm_ruby_string, 'ruby-2.0.0-p0'

set :user, "stack"
set :ssh_options, { :forward_agent => true }

before 'deploy:setup', 'rvm:install_rvm'  # install/update RVM
before 'deploy:setup', 'rvm:install_ruby' # install Ruby and create gemset, OR:

namespace :deploy do
  desc "Restart all of the build workers"
  task :restart, :roles => :worker do
    run 'sudo /etc/init.d/kochiku-worker restart'
  end
end
