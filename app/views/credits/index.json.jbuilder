json.array!(@credits) do |credit|
  json.extract! credit, :id, :user_id, :achievement_id
  json.url credit_url(credit, deserialize_format: :json)
end
