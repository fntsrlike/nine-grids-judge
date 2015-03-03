json.array!(@users) do |user|
  json.extract! user, :id, :username, :realname, :email, :phone
  json.url user_url(user, format: :json)
end
