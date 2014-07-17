class Truck < ActiveRecord::Base
    # attr_accessilble :name, :twitter_user_name, :address, :latitude, :longitude
    attr_accessor :tweet
    geocoded_by :address
   
	def self.configure_twitter
        twitter_client = Twitter::REST::Client.new do |config|
			config.consumer_key = Foodtruckmap.config.twitter_consumer_key
			config.consumer_secret = Foodtruckmap.config.twitter_consumer_secret
			config.access_token = Foodtruckmap.config.twitter_access_token
			config.access_token_secret = Foodtruckmap.config.twitter_access_token_secret
		end

        return twitter_client
	end

    def self.build_regexp
        cardinalStreetNames = "[0-9]+#{RegExpType(CardinalSuffix)}?"
        allStreetNames = "(#{cardinalStreetNames}|#{RegExpType(NewYorkStreetNames)})"
        fullStreetName = "(#{RegExpType(StreetPrefixSuffix)}\\s*)?#{allStreetNames}\\s*(#{RegExpType(StreetPrefixSuffix)}\\W)?\\s*#{RegExpType(StreetTypes)}?"
        fullProperStreetName = "(#{RegExpType(StreetPrefixSuffix)}\\s*)?#{allStreetNames}\\s*(#{RegExpType(StreetPrefixSuffix)}\\W)?\\s*#{RegExpType(StreetTypes)}"
        intersection = "#{fullStreetName}\\W*((and|n|\\/|\\|\\+|&|&amp;|@)\\W*)+#{fullStreetName}"
        includeBetween = "(#{fullStreetName}\\W*(b.*w.*|bet)\\W*)?#{intersection}"
        address = "[0-9]+\\W+#{fullProperStreetName}"

        finalRegExpString = "([^']\\b#{includeBetween}|#{address})\\b"
        Regexp.new(finalRegExpString, Regexp::IGNORECASE)
    end

	def get_tweets
        twitter_client = Truck.configure_twitter
        
        twitter_client.user_timeline(twitter_user_name, :count=>200)
	end

    def get_profile_image
        
        if @tweet == nil
            user = Truck.configure_twitter.user(twitter_user_name)
        else
            user = @tweet.user
        end
        
        image_url = user.profile_image_url(size = :normal)

        return image_url.to_s
    end

    def contains_address(tweet_text)
        Truck.build_regexp.match(tweet_text)
    end

    def extract_address(tweet_text)
        match = Truck.build_regexp.match(tweet_text)
        if match == nil
            return ""
            else
            return match[0]
        end
    end

    def get_most_recent_tweet_with_address
        tweets = self.get_tweets
        for tweet in tweets
            if self.contains_address(tweet.text)
                @tweet = tweet
                return tweet
            end
        end
        
        return ""
    end

    def get_address
        tweet = self.get_most_recent_tweet_with_address
        address = self.clean_address(self.contains_address(tweet.text)[0])
        return address
    end

    def clean_address(address)
        if address == nil
            return ""
        end
        address
        address = address.sub("&amp;","and")
        address = address.sub("@","and")
        address = address.sub("btwn","between")
        address = address.sub("bet ","between ")
        address = address.strip
        return address
    end

    def add_city_to_address(address)
        if address.length > 0
            tweet_text = self.get_most_recent_tweet_with_address.text.downcase
            if Regexp.new("(^|\\W+)#{RegExpType(BrooklynNames)}($|\\W+)", Regexp::IGNORECASE).match(tweet_text)
                address << ", Brooklyn, NY"
                else
                address << ", Manhattan, NY"
            end
        end
        return address
    end

    def update_address
        new_address = self.add_city_to_address(self.get_address)
        if new_address != self.address
            self.address = new_address
            return true
            else
            return false
        end
    end

    def geocode_address(address)
        if address.length == 0
            return [nil,nil]
        end
        if address.include?("between")
            raw_address = self.get_address
            first_street = Regexp.new(".+(?=\\W+between)", Regexp::IGNORECASE).match(raw_address)
            first_cross_street = Regexp.new("(?<=between\\s).+(?=\\sand)", Regexp::IGNORECASE).match(raw_address)
            second_cross_street = Regexp.new("(?<=\\Wand\\W).+", Regexp::IGNORECASE).match(raw_address)
            if (first_street == nil)
                first_street = ""
                else
                first_street = first_street[0]
            end
            if (first_cross_street == nil)
                first_cross_street = ""
                else
                first_cross_street = first_cross_street[0]
            end
            if (second_cross_street == nil)
                second_cross_street = ""
                else
                second_cross_street = second_cross_street[0]
            end
            first_intersection = add_city_to_address(first_street + " and " + first_cross_street)
            second_intersection = add_city_to_address(first_street + " and " + second_cross_street)
            first_geocode = Geocoder.search(first_intersection)
            second_geocode = Geocoder.search(second_intersection)
            
            latitude = (first_geocode[0].coordinates()[0] + second_geocode[0].coordinates()[0])/2
            longitude = (first_geocode[0].coordinates()[1] + second_geocode[0].coordinates()[1])/2
            return [latitude,longitude]
            else
            geocode = Geocoder.search(address)
            latitude = geocode[0].coordinates()[0]
            longitude = geocode[0].coordinates()[1]
            return [latitude,longitude]
        end
    end

    def geocode_truck
        if self.update_address
            if self.address.include?("between")
                geocode = geocode_address(self.get_address)
                
                self.latitude = geocode[0]
                self.longitude = geocode[1]
                self.save
                else
                self.geocode
                self.save
            end
        end
    end

end
