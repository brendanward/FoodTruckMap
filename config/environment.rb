# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

def update_twitter_trucks(date)
  trucks = TwitterTruck.all
    
  trucks.each do |truck|
    tweets = truck.get_timeline_since(date)
    
    tweets.each do |t|
      tweet = Tweet.new
      tweet.twitter_id = t.id
      tweet.twitter_user_id = t.user.id
      tweet.text = t.text
      tweet.tweet_created_at = t.created_at
      
      tweet.save
    end
  end
end




