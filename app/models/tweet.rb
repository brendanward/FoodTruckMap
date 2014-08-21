class Tweet < ActiveRecord::Base
  before_save :clean_text
  include TwitterAccessor
  
  @@last_updated = nil
  
  private
  def clean_text
    self.text = self.text.gsub(/&(amp;)+/i,"&")
  end
  
  public
  def self.update_tweets
    max_id = Tweet.maximum(:twitter_id)
    max_created_at = Tweet.maximum(:created_at)
    
    tweets = []
    
    unless max_id.nil?
      tweets = get_list_tweets_since(max_id) if (@@last_updated.nil? || (Time.now - @@last_updated) > (5 * 60))
      @@last_updated = Time.now
    else
      tweets = get_list_tweets_since(DateTime.now.in_time_zone("EST").beginning_of_day)
    end
    
    tweets.each do |t|
      tweet = Tweet.new
      tweet.twitter_id = t.id
      tweet.twitter_user_id = t.user.id
      tweet.text = t.text
      tweet.tweet_created_at = t.created_at
      
      tweet.save
    end     
  end
  
  def self.update_older_tweets_since(date)
    min_id = Tweet.minimum(:twitter_id)
    
    tweets = []
    
    tweets = get_list_tweets_since(date,min_id)
    
    puts "Got #{tweets.count.to_s} Tweets"
    
    tweets.each do |t|
      tweet = Tweet.new
      tweet.twitter_id = t.id
      tweet.twitter_user_id = t.user.id
      tweet.text = t.text
      tweet.tweet_created_at = t.created_at
      
      tweet.save
    end     
  end
  
  def self.get_twitter_rate_limit_status
    status = get_rate_limit_status
    status[:resources][:lists]
  end
  
  def contains_address?
    address = AddressExtractor.extract_address(self.text)
    return address.length > 0
  end
  
  def extract_address
    AddressExtractor.extract_address(self.text)
  end
  
  def extract_city
    AddressExtractor.extract_city(self.text)
  end
  
  def get_coordinates
    AddressExtractor.geocode_address(self.extract_address,self.extract_city)
  end

end
