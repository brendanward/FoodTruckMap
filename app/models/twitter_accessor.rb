class TwitterAccessor < ActiveRecord::Base
  
  def self.configure_twitter
    twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key = Foodtruckmap.config.twitter_consumer_key
      config.consumer_secret = Foodtruckmap.config.twitter_consumer_secret
      config.access_token = Foodtruckmap.config.twitter_access_token
      config.access_token_secret = Foodtruckmap.config.twitter_access_token_secret
    end

    return twitter_client
	end
  
  def self.get_current_day_tweets
    client = TwitterAccessor.configure_twitter
    tweets = []
    date = DateTime.now.beginning_of_day
    max_id = 0
    
    while date == DateTime.now.beginning_of_day do
      all_tweets = []
      
      if max_id == 0
        all_tweets = client.list_timeline(:slug=>"foodtrucks",:count=>20,:include_rts=>false)
      else
        all_tweets = client.list_timeline(:slug=>"foodtrucks",:max_id=>max_id-1,:count=>20,:include_rts=>false)
      end
      
      for tweet in all_tweets
        date = tweet.created_at.beginning_of_day
        max_id = tweet.id
        if date == DateTime.now.beginning_of_day
          tweets.push(tweet)
        else
          break
        end
      end
    end
    
    return tweets
  end

end
