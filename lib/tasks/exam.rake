namespace :exam do
  desc "關於章節、題目的相關工作"

  # 建立大量的假章節與假題目
  task fake: :environment do
    for i in 1..12
      Chapter.create(number: "CH#{i}", title: "第#{i}章標題", description: "第#{i}章內文", weight: i)
      for j in "A".."O"
        Quiz.create(title: "第#{j}題", content: "問題#{j}", reference: "參考答案#{j}", chapter_id: i)
      end

      puts "Created CH#{i} and it's quizes."
    end
  end

end