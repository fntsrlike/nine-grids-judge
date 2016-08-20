class StudentMailer < ActionMailer::Base
  if Rails.env.production?
    default from: ENV["SMTP_FROM"]
  else
    default from: "from@example.com"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.student_mailer.resetPwd.subject
  #
  def resetPwd(user, password)
    @course_name = Rails.env.production? ? ENV["COURSE_NAME"] : "Compiler"
    @user = user
    @password = password

    mail to: user.email, subject: "Welcome to #{@course_name} course"
  end
end
