json.array!(@chapters) do |chapter|
  json.extract! chapter, :id, :number, :title, :description, :weight, :status
  json.url chapter_url(chapter, format: :json)
end
