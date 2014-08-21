module TwitterAccessor
  def self.included base
    base.send :include, InstanceMethods
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
      client = TwitterAccessor.configure_twitter
      return client.list_members(:slug=>"foodtrucks")
    end
    
    def get_list_tweets_since(since_value, max_id = 0)
      client = TwitterAccessor.configure_twitter
      twitter_params = {:slug=>"foodtrucks", :count=>200, :include_rts=>false}
      tweets = []
      puts "get_tweets_since called with #{since_value} and #{max_id}"

      if (since_value.is_a?(Date) || since_value.is_a?(Time))
        date = DateTime.now.in_time_zone("EST")

        while date >= since_value do
          returned_tweets = []
          twitter_params[:max_id] = max_id - 1 unless max_id.nil?

          returned_tweets = client.list_timeline(twitter_params)

          break if returned_tweets.count == 0 
            
          returned_tweets.each do |tweet|
            date = tweet.created_at
            max_id = tweet.id
            date >= since_value ? tweets << tweet : break
          end
        end
      elsif since_value.is_a?(Integer)  
        twitter_params[:since_id] = since_value
        tweets += client.list_timeline(twitter_params)    
        tweets_returned = tweets.count

        while tweets_returned > 0 do
          twitter_params[:max_id] = tweets.last.id - 1
          returned_tweets = client.list_timeline(twitter_params)
          
          break if returned_tweets.count == 0 
          
          tweets += returned_tweets
          tweets_returned = returned_tweets.count
        end
      end      

      return tweets
    end
    
    def get_rate_limit_status
      client = TwitterAccessor.configure_twitter
      client.get('/1.1/application/rate_limit_status.json')[:body]
    end
  end    
  
  module InstanceMethods
    def get_timeline_for_user(twitter_id)
      client = TwitterAccessor.configure_twitter
      client.user_timeline(twitter_id, :count=>200, :include_rts=>false, :exclude_replies=>true)
    end
    
    def get_timeline_for_user_since(twitter_id,since_date)
      client = TwitterAccessor.configure_twitter
      twitter_params = {:user_id=>twitter_id, :count=>200, :include_rts=>false, :exclude_replied=>true}
      first_tweet = Tweet.where("twitter_user_id = '#{twitter_id.to_s}'").order(:twitter_id).first
      first_tweet ? max_id = first_tweet.twitter_id : max_id = nil
      
      tweets = []
      date = DateTime.now.in_time_zone("EST")

      while date >= since_date do
        returned_tweets = []

        twitter_params[:max_id] = max_id - 1 unless max_id.nil?
        returned_tweets = client.user_timeline(twitter_params)

        break if returned_tweets.count == 0 
            
        returned_tweets.each do |tweet|
          date = tweet.created_at
          max_id = tweet.id
          date >= since_date ? tweets << tweet : break
        end
      end
      
      return tweets
    end
  end
end