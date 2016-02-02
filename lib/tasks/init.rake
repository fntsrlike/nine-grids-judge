namespace :init do
  desc "Initial system"
  task build: ["tmp:clear", "log:clear", "db:drop", "db:create", "db:migrate"]

  task admin: :environment do
    accounts = [
      ['Amdin', 'amdin', 'admin@foo.bar', '0912-345678', 'admin'],
      # ['Manager', 'manager', 'manager@foo.bar', '0912-345678', 'manager'],
      # ['Student', 'student', 'student@foo.bar', '0912-345678', 'student'],
    ]

    duplicate = []

    accounts.each do |row|
      if User.exists?(username: row[1]) or User.exists?(email: row[2])
        duplicate.push(row[1])
      else
        user = User.create(realname: row[0], username: row[1], email: row[2],  phone: row[3], password: row[4])
        user.add_role :admin
        puts "Create accounts #{row[1]}"
      end
    end

    if !duplicate.empty?
      duplicate = duplicate.join(',')
      puts "Duplicate user: #{duplicate}"
    end

    puts "Done!"
  end

  # task fake: :environment do
  #     puts "Create fake data for development"

  #     User.skip_callback(:create, :after, :send_mail)
  #     Applicant.skip_callback(:create, :after, :send_mail)
  #     Paper.skip_callback(:create, :after, :send_mail)

  #     # admin
  #     puts "\t正在建立 admin"
  #     u = User.new(name: "系統管理員", username: "admin", password: "qwer1234", email: "admin@foo.bar")
  #     u.save!
  #     u.add_role :admin

  #     # manager
  #     g_manager(ENV['managers_count'].to_i)

  #     # assigners
  #     num = Category.all.count == 0 ? ENV['assigners_count'].to_i : Category.all.count
  #     g_assigner(num)

  #     # reviewers
  #     g_reviewer(ENV['reviewers_count'].to_i)

  #     # contributors
  #     g_contributor(ENV['contributors_count'].to_i)

  #     # applicants
  #     g_applicant(ENV['applicants_count'].to_i)

  # end
end