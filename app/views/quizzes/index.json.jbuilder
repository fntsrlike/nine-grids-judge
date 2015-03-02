json.array!(@quizzes) do |quiz|
  json.extract! quiz, :id, :code, :title, :content, :chapter_id
  json.url quiz_url(quiz, format: :json)
end
