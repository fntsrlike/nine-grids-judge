require 'csv'

namespace :user do
  desc "關於使用者的相關工作"

  # 建立測試用的基本帳號
  task basic: :environment do
    puts "Generate basic testing accounts"

    puts "----------------------\n"

    rows  = [
      ["系統管理員", "admin", "qwer1234", "admine@foo.bar", "0912345678", :admin],
      ["助教測試帳號",  "manager", "qwer1234", "manager@foo.bar", "0912345678", :manager],
      ["學生測試帳號",  "student", "qwer1234", "student@foo.bar", "0912345678", :student],
    ]

    create_accounts(rows)

    puts "Done!"
  end

  # 匯入 CSV 檔以建立帳號
  task :import, [:filename] => :environment do |t, args|
    if !File.exist?(args[:filename])
      puts "Files not exist!"
    else
      puts "Reading file: #{args[:filename]}"

      puts "----------------------\n"

      rows = CSV.read(args[:filename])
      create_accounts(rows)

      puts "Done!"
    end
  end

  # 重設特定使用者的密碼，並發送通知信
  task :passwd, [:username] => :environment do |t, args|
    puts "Begining to reset user password and send email to notify."
    username = args[:username]
    user = User.where(username: username).first

    if user.nil?
      puts "Can't find '#{args[:username]}', please check again"
      next
    end

    password = Array.new(32){[*"a".."z", *"A".."Z", *"0".."9"].sample}.join
    user.password = password

    unless user.save
      puts "Reset failed!"
      next
    end

    StudentMailer.resetPwd(user, password).deliver
    puts "Reset password of #{user.username} successfully. Notify has been sent."
  end

  # 重設所有學生的密碼，並發送通知信
  task :passwd_student => :environment do
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



  # 透過 CSV 的資料去建立帳號
  def create_accounts(rows)
    errors = []

    rows.each do |row|
      account = parse(row)
      title = "#{account[:username]} (#{account[:realname]})"

      # 若建立失敗則記錄到清單中
      unless create(account)
        errors.push(title)
      end
    end

    puts "----------------------"

    if errors.size > 0
      puts "Failed: #{errors.join(',')}"
    end
  end

  # 解析 CSV 的單列，並轉成 Hash
  def parse(row)
    account = {
      realname: row[0],
      username: row[1],
      password: row[2],
      email: row[3],
      phone: row[4],
      role: row[5]
    }
  end

  # 建立帳號
  def create(account)
    valid_roles = [:admin, :manager, :student]
    role = account[:role]

    user = User.new(
      realname: account[:realname],
      username: account[:username],
      email: account[:email],
      phone: account[:phone],
      password: account[:password],
    )

    unless user.save
      puts "Failed to create user #{user.username}(#{user.realname}), because of #{user.errors.full_messages}"
      return false
    end

    if valid_roles.include? (role)
      user.add_role role
    else
      user.add_role :student
    end

    puts "Created user #{user.username}(#{user.realname}) successfully!"
    return true
  end
end
