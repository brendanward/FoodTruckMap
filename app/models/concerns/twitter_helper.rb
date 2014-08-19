module TwitterHelper
  def self.included base
    #base.send :include, InstanceMethods
    base.extend ClassMethods
  end
  
  def self.configure_twitter
    twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key = Foodtruckmap.config.twitter_consumer_key
      config.consumer_secret = Foodtruckmap.config.twitter_consumer_secret
      config.access_token = Foodtruckmap.config.twitter_access_token
      config.access_token_secret = Foodtruckmap.config.twitter_access_token_secret
    end

    return twitter_client
  end
  
  module ClassMethods    
    def get_list_members
      client = TwitterHelper.configure_twitter
      return client.list_members(:slug=>"foodtrucks")
    end
    
    def get_tweets_since(since_value)
      client = TwitterHelper.configure_twitter
      tweets = []
      puts "get_tweets_since called with #{since_value}"

      if (since_value.is_a?(Date) || since_value.is_a?(Time))
        date = DateTime.now.in_time_zone("EST")
        max_id = 0

        while date >= since_value do
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
      elsif since_value.is_a?(Integer)      
        tweets += client.list_timeline(:slug=>"foodtrucks",:count=>200,:since_id=>since_value,:include_rts=>false)    
        tweets_returned = tweets.count

        while tweets_returned > 0 do
          max_id = tweets.last.id
          returned_tweets = client.list_timeline(:slug=>"foodtrucks",:count=>200,:max_id=>max_id-1,:since_id=>since_value,:include_rts=>false)

          tweets += returned_tweets
          tweets_returned = returned_tweets.count
        end
      end      

      return tweets
    end
    
    def get_rate_limit_status
      client = TwitterHelper.configure_twitter
      client.get('/1.1/application/rate_limit_status.json')[:body]
    end
    
  end    
end