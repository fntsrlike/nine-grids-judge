json.array!(@answers) do |answer|
  json.extract! answer, :id, :user_id, :content, :status
  json.url answer_url(answer, format: :json)
end
