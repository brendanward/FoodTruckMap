class AddressExtractor
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

  def self.build_between_regex
    cardinalStreetNames = "[0-9]+#{RegExpType(CardinalSuffix)}?"
    allStreetNames = "(#{cardinalStreetNames}|#{RegExpType(NewYorkStreetNames)})"
    fullStreetName = "(#{RegExpType(StreetPrefixSuffix)}\\s*)?#{allStreetNames}\\s*(#{RegExpType(StreetPrefixSuffix)}\\W)?\\s*#{RegExpType(StreetTypes)}?"
    intersection = "#{fullStreetName}\\W*((and|n|\\/|\\|\\+|&|&amp;|@)\\W*)+#{fullStreetName}"
    includeBetween = "(#{fullStreetName}\\W*(b.*w.*|bet|bw|b/t|\\s|)\\W*)#{intersection}"

    finalRegExpString = "([^']\\b#{includeBetween})\\b"
    Regexp.new(finalRegExpString, Regexp::IGNORECASE)
  end

  def self.extract_address(tweet_text)
    match = Truck.build_regexp.match(tweet_text)
    if match == nil
      return ""
    else
      return match[0]
    end
  end

  def self.extract_city(tweet_text)
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

  def self.clean_address(address)
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

  def self.geocode_address(address, city_state)
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
end