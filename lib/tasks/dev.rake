namespace :dev do
  desc "Initial system"

  task build: ["tmp:clear", "log:clear", "db:drop", "db:create", "db:migrate"]
  task reset: ["assets:precompile", :restart]

  task :restart do
    puts `touch tmp/restart.txt`
  end
end