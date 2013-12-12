require 'capistrano/version'
require "./config/deploy_hosts"

require 'bundler/capistrano' # adds bundle:install step to deploy pipeline

default_run_options[:env] = {'PATH' => '/usr/local/bin:$PATH'}

set :application, "Kochiku Worker"
set :repository,  "https://github.com/where/kochiku-worker.git"
set :branch, "master"
set :scm, :git

set :user, "kochiku"
set :deploy_to, "/app/kochiku-worker"
set :deploy_via, :remote_cache
set :keep_releases, 5
set :use_sudo, false

role :worker, *HostSettings.worker_hosts

after "deploy:setup", "kochiku:setup"
after "deploy:create_symlink", "kochiku:symlinks"
after "deploy:create_symlink", "kochiku:create_kochiku_worker_yaml"

namespace :kochiku do
  task :setup, :roles => :worker  do
    run "gem install bundler -v '~> 1.3' --conservative"
    run "mkdir -p #{shared_path}/build-partition"
  end

  task :symlinks, :roles => :worker do
    run "ln -nfFs #{shared_path}/build-partition #{current_path}/tmp/build-partition"
  end

  task :create_kochiku_worker_yaml, :roles => :worker  do
    config =
      [ "build_master: #{HostSettings.kochiku_web_host}",
        'build_strategy: build_all',
        "redis_host: #{HostSettings.redis_host}" ]

    run "echo '#{config.join("$")}' | tr '$' '\n' > #{current_path}/config/kochiku-worker.yml"
  end

  task :cleanup_zombies, :roles => :worker do
    run "ps -eo 'pid ppid comm' |grep -i resque |grep Paused | awk '$2 == 1 { print $1 }' | xargs kill"
  end
end

# load installation specific capistrano config
if File.exist?(custom_deploy_config = File.expand_path('deploy.custom.rb', File.dirname(__FILE__)))
  load custom_deploy_config
end
