# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(realname: "系統管理員", username: "admin", password: "admin", email: "admine@foo.bar", phone:"0912345678")
User.create(realname: "助教測試帳號", username: "manager", password: "manager", email: "manager@foo.bar", phone:"0912345678")
User.create(realname: "學生測試帳號", username: "student", password: "student", email: "student@foo.bar", phone:"0912345678")

for i in 1..12
  Chapter.create(number: "CH#{i}", title: "第#{i}章標題", description: "第#{i}章內文", weight: i)
  for j in "A".."O"
    Quiz.create(title: "第#{j}題", content: "問題#{j}", reference: "參考答案#{j}", chapter_id: i)
  end
end