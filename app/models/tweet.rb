class Tweet < ActiveRecord::Base
  include TwitterHelper
  
  def self.update_tweets
    max_id = Tweet.maximum(:twitter_id)
    max_created_at = Tweet.maximum(:created_at)
    
    tweets = []
    
    if max_id
      tweets = get_tweets_since(max_id) if (Time.now - max_created_at) > (5 * 60)
    else
      tweets = get_tweets_since(DateTime.now.in_time_zone("EST").beginning_of_day)
    end
    
    tweets.each do |t|
      tweet = Tweet.new
      tweet.twitter_id = t.id
      tweet.twitter_user_id = t.user.id
      tweet.text = t.text.gsub(/&(amp;)+/i,"&")
      tweet.tweet_created_at = t.created_at
      
      tweet.save
    end     
  end
end
