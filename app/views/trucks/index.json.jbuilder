json.array!(@trucks) do |truck|
  json.extract! truck, :id, :name, :twitter_user_name, :latitude, :longitude, :address
  json.url truck_url(truck, format: :json)
end
