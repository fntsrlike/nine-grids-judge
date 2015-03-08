require 'csv'

namespace :students do
  desc "Imports a CSV file and create mass users"
  task :create, [:filename] => :environment do |t, args|
    if !File.exist?(args[:filename])
      puts "Files not exist!"
    else
      puts "Reading file: #{args[:filename]}"
      data = CSV.read(args[:filename])
      duplicate = []

      data.each do |row|
        if User.exists?(username: row[1]) or User.exists?(email: row[2])
          duplicate.push(row[1])
        else
          password = Array.new(32){[*"a".."z", *"A".."Z", *"0".."9"].sample}.join
          user = User.create(realname: row[0], username: row[1], email: row[2],  phone: row[3], password: password)
          user.add_role :student
          puts "Create student #{row[1]}"
        end
      end

      if !duplicate.empty?
        duplicate = duplicate.join(',')
        puts "Duplicate user: #{duplicate}"
      end

      puts "Done!"
    end
  end

  task :reset_pwd => :environment do
    User.with_role(:student).each do |user|
      password = Array.new(32){[*"a".."z", *"A".."Z", *"0".."9"].sample}.join
      user.update(password: password)

      if user.save
        StudentMailer.resetPwd(user, password).deliver
      end
    end
  end
end
