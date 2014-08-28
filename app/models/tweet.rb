class Tweet < ActiveRecord::Base
  before_save :clean_text
  include TwitterAccessor
  include RegexpBuilder
  
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
  
  def clean_text_for_regex
    text = self.text.downcase.partition(/\b(tomorrow|tmrw|sunday|sun|monday|mon|tuesday|tue|wednesday|wed|thrusday|thur|friday|fri|saturday|sat)\b/)[0]
    text = text.gsub(/\$[0-9]+/i,'') #removes $ amounts
    text = text.gsub(/[0-9]+:[0-9]+/i,'') #removes times written as 1:00
    text = text.gsub(/[0-9:-]+\s?(am|pm)/i,'') #removes times written as 1am
    text = text.gsub(/((\([0-9]{3}\))\W*|[0-9]{3}-?)?[0-9]{3}-?[0-9]{4}/i,'') #removes phone number
    text = text.gsub(/(@|#)[a-z0-9]+/i,'') #removes hashtags and retweets
    text = text.gsub(/(from|today|tomorrow|tom|tonight)\W*[0-9]+\W*(-|to)\W*[0-9]+/i,'') #remove time ranges
    text = text.gsub(/[0-9]+\W*(-|to)\W*[0-9]+\W*(from|today|tomorrow|tom|tonight)/i,'') #remove time ranges
    text = text.gsub(/[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{2,4}/i,'') #remove full dates
    text = text.gsub(/http\S+\b/i,'')
    text = text.gsub(/(jan|january|feb|february|march|april|may|june|july|aug|august|sep|september|oct|october|nov|november|dec|december)\W*[0-9]+\S?[0-9]+/i,'')
    text = text.gsub(/(,|\.)/i,'')
    #text = text.gsub(/[0-9]//[0-9]/i,"") #attempt at removing dates (not working)
    
    text = text.gsub(/\b(betw|btwn|bw|btw|bet|b\/t|b\\t|b\/w|b\\w|in\s+between)\b/i,' between ')
    
    text = text.gsub(/\bmad\b/i," Madison ")
    text = text.gsub(/\blex\b/i," Lexington ")
    text = text.gsub(/\bbway\b/i," Broadway ")
    text = text.gsub(/\bb'way\b/i," Broadway ")
    
    #text = text.gsub(/\//i,' / ')
    #text = text.gsub(/\\/i,' \ ')
    
    return text.squeeze(" ")
  end
  
  
  def contains_address?
    match = get_regexp(final_regexp_string).match(clean_text_for_regex)
    return !match.nil?
  end
  
  def extract_address
    match = get_regexp(final_regexp_string).match(clean_text_for_regex)
    
    return "" if match.nil? 
    
    return match[0].strip
  end
  
  def extract_city    
    return "Brooklyn, NY" if get_regexp(brooklyn_regexp).match(clean_text_for_regex)
    return "Queens, NY" if get_regexp(queens_regexp).match(clean_text_for_regex)
    return "New York, NY"
  end  
  
  def extract_full_address
    self.extract_address << ", " << self.extract_city
  end
  
  def get_coordinate
    full_address = self.extract_full_address
    
    return Coordinate.find_coordinate(full_address)
    
   # coordinate = Coordinate.find_by address: full_address
    
   # if coordinate.nil?
   #   coordinate = Coordinate.new
   #   coordinate.address = full_address
   #   coordinate.geocode_address
   #   puts "NIL COORDINATES!! #{full_address}" if (coordinate.latitude.nil? || coordinate.longitude.nil?)
   #   coordinate.save unless coordinate.latitude.nil? || coordinate.longitude.nil?
   # end
    
   # return coordinate
  end

end
