json.array!(@quizzes) do |quiz|
  json.extract! quiz, :id, :title, :content, :chapter_id
  json.url quiz_url(quiz, format: :json)
end
