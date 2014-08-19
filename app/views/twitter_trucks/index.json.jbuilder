json.array!(@twitter_trucks) do |twitter_truck|
  json.extract! twitter_truck, :id, :twitter_use_id, :user_name, :image_path
  json.url twitter_truck_url(twitter_truck, format: :json)
end
