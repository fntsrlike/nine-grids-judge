namespace :dev do
  desc "Initial system"

  task build: ["tmp:clear", "log:clear", "db:drop", "db:create", "db:migrate"]
  task reset: ["tmp:cache:clear", "assets:precompile", :restart]

  task :restart do
    puts `touch tmp/restart.txt`
  end
end