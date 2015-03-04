json.array!(@chapters) do |chapter|
  json.extract! chapter, :id, :number, :title, :decription, :weight, :status
  json.url chapter_url(chapter, format: :json)
end
