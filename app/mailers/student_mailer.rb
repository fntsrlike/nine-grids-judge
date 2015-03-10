class StudentMailer < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.student_mailer.resetPwd.subject
  #
  def resetPwd user, password
    @course_name = "Compiler"
    @user = user
    @password = password

    mail to: user.email, subject: "Welcome to #{@course_name} course"
  end
end
