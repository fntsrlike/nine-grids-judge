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
    puts "Begining to reset user password and send email to notify."
    User.with_role(:student).each do |user|
      password = Array.new(32){[*"a".."z", *"A".."Z", *"0".."9"].sample}.join
      user.update(password: password)

      if user.save
        StudentMailer.resetPwd(user, password).deliver
        puts "Send email to #{user.username} successed!"
      else
        puts "Send email to #{user.username} failed!"
      end
    end
  end

  task :reset_pwd_specify, [:username] => :environment do |t, args|
    puts "Begining to reset user password and send email to notify."
    user = User.where(username: args[:username]).first
    if user.nil?
      puts "Can't find #{args[:username]}, please check again"
    else
      password = Array.new(32){[*"a".."z", *"A".."Z", *"0".."9"].sample}.join
      user.update(password: password)

      if user.save
        StudentMailer.resetPwd(user, password).deliver
        puts "Send email to #{user.username} successed!"
      else
        puts "Send email to #{user.username} failed!"
      end
    end
  end
end
