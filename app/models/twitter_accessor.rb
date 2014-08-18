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
  
  def self.get_rate_limit_status
    client = TwitterAccessor.configure_twitter
    client.get('/1.1/application/rate_limit_status.json')[:body]
  end
  
  def self.get_tweets_since_day(earliest_date)
    client = TwitterAccessor.configure_twitter
    tweets = []
    date = DateTime.now.in_time_zone("EST")
    max_id = 0
    
    while date >= earliest_date do
      all_tweets = []
      
      if max_id == 0
        all_tweets = client.list_timeline(:slug=>"foodtrucks",:count=>200,:include_rts=>false)
      else
        all_tweets = client.list_timeline(:slug=>"foodtrucks",:max_id=>max_id-1,:count=>200,:include_rts=>false)
      end
      
      for tweet in all_tweets
        date = tweet.created_at.in_time_zone("EST").beginning_of_day
        max_id = tweet.id
        if date == DateTime.now.in_time_zone("EST").beginning_of_day
          tweets << tweet
        else
          break
        end
      end
    end
    
    return tweets
  end
  
  def self.get_all_trucks
    client = TwitterAccessor.configure_twitter
    trucks = client.list_members(:slug=>"foodtrucks")
    
    return trucks
  end
  
  def self.get_tweet_for_each_truck
    truck_tweets = Hash.new
      
    tweets = TwitterAccessor.get_tweets_since_day(DateTime.now.in_time_zone("EST").beginning_of_day)
    
    for tweet in tweets
      user_id = tweet.user.id
      if truck_tweets[user_id] == nil
        tweet_text = tweet.text.gsub(/&(amp;)+/i,"&")
        address = AddressExtractor.extract_address(tweet_text)
        if address.length > 0        
          truck_tweets[user_id] = tweet
        end
      end
    end
    
    return truck_tweets
  end
end
