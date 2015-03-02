json.array!(@judgements) do |judgement|
  json.extract! judgement, :id, :answer_id, :user_id, :content
  json.url judgement_url(judgement, format: :json)
end
