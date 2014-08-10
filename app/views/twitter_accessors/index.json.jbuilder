json.array!(@twitter_accessors) do |twitter_accessor|
  json.extract! twitter_accessor, :id
  json.url twitter_accessor_url(twitter_accessor, format: :json)
end
