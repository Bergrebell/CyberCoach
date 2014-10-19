json.array!(@users) do |user|
  json.extract! user, :id, :name
  json.url user_url(user, deserialize_format: :json)
end
