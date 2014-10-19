json.array!(@achievements) do |achievement|
  json.extract! achievement, :id, :title, :points, :category_id
  json.url achievement_url(achievement, deserialize_format: :json)
end
