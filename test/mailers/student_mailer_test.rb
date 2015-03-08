require 'test_helper'

class StudentMailerTest < ActionMailer::TestCase
  test "resetPwd" do
    mail = StudentMailer.resetPwd
    assert_equal "Resetpwd", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
