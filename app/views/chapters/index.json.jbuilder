json.array!(@chapters) do |chapter|
  json.extract! chapter, :id, :number, :title, :decription, :weight, :is_active
  json.url chapter_url(chapter, format: :json)
end
