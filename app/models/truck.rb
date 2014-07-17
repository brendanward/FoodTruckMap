class Truck < ActiveRecord::Base
    # attr_accessilble :name, :twitter_user_name, :address, :latitude, :longitude
    attr_accessor :tweet
   
	def self.configure_twitter
        client = Twitter::REST::Client.new do |config|
			config.consumer_key = Foodtruckmap.config.twitter_consumer_key
			config.consumer_secret = Foodtruckmap.config.twitter_consumer_secret
			config.access_token = Foodtruckmap.config.twitter_access_token
			config.access_token_secret = Foodtruckmap.config.twitter_access_token_secret
		end
	end

	def get_tweets
        #  	Truck.configure_twitter
        twitter_client = Twitter::REST::Client.new do |config|
			config.consumer_key = Foodtruckmap.config.twitter_consumer_key
			config.consumer_secret = Foodtruckmap.config.twitter_consumer_secret
			config.access_token = Foodtruckmap.config.twitter_access_token
			config.access_token_secret = Foodtruckmap.config.twitter_access_token_secret
		end
        
        twitter_client.user_timeline(twitter_user_name, :count=>200)
	end

    def contains_address(tweet_text)
        return false
    end
	
end
