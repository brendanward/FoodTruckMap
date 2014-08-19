json.array!(@twitter_trucks) do |twitter_truck|
  json.extract! twitter_truck, :id, :twitter_user_id, :twitter_scree_name, :name, :image_url
  json.url twitter_truck_url(twitter_truck, format: :json)
end
