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
    includeBetween = "(#{fullStreetName}\\W*(b.*w.*|bet|bw|b/t|\\s|)\\W*)?#{intersection}"
    address = "\\b[0-9]+\\W+#{fullProperStreetName}"

    finalRegExpString = "([^']\\b#{includeBetween}|#{address})\\b"
    Regexp.new(finalRegExpString, Regexp::IGNORECASE)
  end

  def self.build_fullstreetname_regexp
    cardinalStreetNames = "[0-9]+#{RegExpType(CardinalSuffix)}?"
    allStreetNames = "(#{cardinalStreetNames}|#{RegExpType(NewYorkStreetNames)})"
    fullStreetName = "(#{RegExpType(StreetPrefixSuffix)}\\s*)?#{allStreetNames}\\s*(#{RegExpType(StreetPrefixSuffix)}\\W)?\\s*#{RegExpType(StreetTypes)}?"

    finalRegExpString = "([^']\\b#{fullStreetName})\\b"
    Regexp.new(finalRegExpString, Regexp::IGNORECASE)
  end

  def self.build_between_regex
    cardinalStreetNames = "[0-9]+#{RegExpType(CardinalSuffix)}?"
    allStreetNames = "(#{cardinalStreetNames}|#{RegExpType(NewYorkStreetNames)})"
    fullStreetName = "(#{RegExpType(StreetPrefixSuffix)}\\s*)?#{allStreetNames}\\s*(#{RegExpType(StreetPrefixSuffix)}\\W)?\\s*#{RegExpType(StreetTypes)}?"
    intersection = "#{fullStreetName}\\W*((and|n|\\/|\\|\\+|&|&amp;|@)\\W*)+#{fullStreetName}"
    includeBetween = "(#{fullStreetName}\\W*(b.*w.*|bet|bw|b/t|\\s|)\\W*)#{intersection}"

    finalRegExpString = "([^']\\b#{includeBetween})\\b"
    Regexp.new(finalRegExpString, Regexp::IGNORECASE)
  end

  def get_tweets(number_of_tweets)
    twitter_client = Truck.configure_twitter        
    twitter_client.user_timeline(twitter_user_name, :count=>number_of_tweets, :include_rts=>false, :exclude_replies=>true)
  end

  def get_profile_image
    if self.profile_image_url_last_updated == nil || (Time.now - self.profile_image_url_last_updated) > (60 * 60 * 24)
      self.profile_image_url = Truck.configure_twitter.user(twitter_user_name).profile_image_url(size = :normal).to_s
      self.profile_image_url_last_updated = Time.now
      self.save
    end
    
    return self.profile_image_url
  end

  def extract_address(tweet_text)
    match = Truck.build_regexp.match(tweet_text)
    if match == nil
      return ""
    else
      return match[0]
    end
  end

  def extract_city(tweet_text)
    tweet_text = tweet_text.downcase
    address = ""
    
    if Regexp.new("(^|\\W+)#{RegExpType(BrooklynNames)}($|\\W+)", Regexp::IGNORECASE).match(tweet_text)
      address = "Brooklyn, NY"
    elsif Regexp.new("(^|\\W+)#{RegExpType(QueensNames)}($|\\W+)", Regexp::IGNORECASE).match(tweet_text)
      address = "Queens, NY"
    else
      address = "Manhattan, NY"
    end

    return address
  end

  def clean_address(address)
    if address == nil
      return ""
    end

    address = address.gsub(/mad\b/i," Madison ")
    address = address.gsub("&"," and ")
    address = address.gsub("@"," and ")
    address = address.gsub("betw "," between ")
    address = address.gsub("btwn"," between ")
    address = address.gsub(/\Wbw\W/i," between ")
    address = address.gsub("btw"," between ")
    address = address.gsub(/bet\b/i," between ")
    address = address.gsub("b/t "," between ")
    address = address.gsub(/b\/w/i," between ")
    address = address.gsub("b\\t "," between ")
    address = address.gsub("b\\w"," between ")
    address = address.gsub("/"," and ")
    address = address.gsub("\\"," and ")
    address = address.strip
    return address
  end

  def geocode_address(address, city_state)
    puts 'GEOCODING: ', address, city_state
    
    if address.length == 0
      return [nil,nil]
    end
    
    bounds = []
    
    if city_state = "Manhattan, NY"
      bounds = [[40.696900,-73.933525],[40.817049,-74.032402]]
    elsif city_state = "Brooklyn, NY"
      bounds = [[40.556714,-73.811989],[40.743217,-74.068108]]
    elsif city_state = "Queens, NY"
      bounds = [[40.546279,-73.665047],[40.804056,-73.998756]]      
    end
    
    if address.include?("between")
    #if Truck.build_between_regexp.match(address)  
      first_street = Regexp.new(".+(?=\\W+between)", Regexp::IGNORECASE).match(address)
      first_cross_street = Regexp.new("(?<=between\\s).+(?=\\sand)", Regexp::IGNORECASE).match(address)
      second_cross_street = Regexp.new("(?<=\\Wand\\W).+", Regexp::IGNORECASE).match(address)
      
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
      
      first_intersection = first_street + " and " + first_cross_street + ", " + city_state
      second_intersection = first_street + " and " + second_cross_street + ", " + city_state
      first_geocode = Geocoder.search(first_intersection, :bounds => bounds)
      second_geocode = Geocoder.search(second_intersection, :bounds => bounds)
      
      puts first_intersection,second_intersection
      
      if first_geocode[0] != nil && second_geocode[0] != nil
        latitude = (first_geocode[0].coordinates()[0] + second_geocode[0].coordinates()[0])/2
        longitude = (first_geocode[0].coordinates()[1] + second_geocode[0].coordinates()[1])/2
        return [latitude,longitude]
      else
        return [nil,nil]
      end
    else
      geocode = Geocoder.search(address + ", " + city_state, :bounds => bounds)
      
      if geocode[0] != nil
        latitude = geocode[0].coordinates()[0]
        longitude = geocode[0].coordinates()[1]
        return [latitude,longitude]
      else
        return [nil,nil]
      end
      
    end
  end

  def geocode_truck
    if self.last_address_update == nil || (Time.now-self.last_address_update) > (5 * 60)
      current_address = self.address
      tweets = self.get_tweets(100)
      
      for tweet in tweets
        tweet_text = tweet.text.gsub(/&(amp;)+/i,"&")
        address = extract_address(tweet_text)
        if address.length > 0
          if tweet.created_at != self.last_address_tweet_time
            @tweet = tweet
            address = clean_address(address)
            city = extract_city(tweet_text)
            full_address = address + ", " + city     
            
            coordinate = Coordinate.find_by address: full_address
            
            if coordinate == nil
              address_coordinate = self.geocode_address(address, city)
            
              coordinate = Coordinate.new

              coordinate.address = full_address
              coordinate.latitude = address_coordinate[0]
              coordinate.longitude = address_coordinate[1]

              if address_coordinate[0] != nil and address_coordinate[1] != nil
                coordinate.save
              end
            end
            
            self.address = full_address
            self.last_address_tweet = tweet_text
            self.last_address_tweet_time = tweet.created_at
            self.latitude = coordinate.latitude
            self.longitude = coordinate.longitude
          end
          
          self.last_address_update = Time.now
          self.save  
          return
        end
      end
    end
  end

  def get_past_locations
    tweets = get_tweets(200)
    past_locations = Array.new
    coordinate_hash = Hash.new

    for tweet in tweets
      tweet_text = tweet.text.gsub(/&(amp;)+/i,"&")
      address = extract_address(tweet_text)
      if address.length > 0
        address = clean_address(address)
        city = extract_city(tweet_text)
        full_address = address + ", " + city
        truck_past_location = TruckPastLocation.new
        
        coordinate = coordinate_hash[full_address]
        
        if coordinate == nil
          
          coordinate = Coordinate.find_by address: full_address

          if coordinate == nil
            sleep(1)
            address_coordinate = geocode_address(address, city)

            coordinate = Coordinate.new

            coordinate.address = full_address
            coordinate.latitude = address_coordinate[0]
            coordinate.longitude = address_coordinate[1]

            coordinate.save
          end
          
          coordinate_hash[full_address] = coordinate
        end
        
        truck_past_location.latitude = coordinate.latitude
        truck_past_location.longitude = coordinate.longitude
        truck_past_location.coordinate_id = coordinate.id
        
        truck_past_location.tweet = tweet_text
        truck_past_location.timestamp = tweet.created_at
        truck_past_location.address = full_address
        past_locations.push(truck_past_location)
      end
    end
    
    return past_locations
  end

end

class TruckPastLocation
  attr_accessor :latitude, :longitude, :tweet, :timestamp, :address, :coordinate_id
end
