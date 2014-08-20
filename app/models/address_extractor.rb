class AddressExtractor
  include AddressTerms
  include NewYorkAddressTerms
  
  def self.regExpType(x)
    "(#{x.join("|")})"
  end

  def self.build_regexp
    cardinalStreetNames = "(?<!\$)[0-9]+#{AddressExtractor.regExpType(CardinalSuffix)}?"
    allStreetNames = "(#{cardinalStreetNames}|#{AddressExtractor.regExpType(NewYorkStreetNames)})"
    fullStreetName = "(#{AddressExtractor.regExpType(StreetPrefixSuffix)}\\s*)?#{allStreetNames}\\s*(#{AddressExtractor.regExpType(StreetPrefixSuffix)}\\W)?\\s*#{AddressExtractor.regExpType(StreetTypes)}?"
    fullProperStreetName = "(#{AddressExtractor.regExpType(StreetPrefixSuffix)}\\s*)?#{allStreetNames}\\s*(#{AddressExtractor.regExpType(StreetPrefixSuffix)}\\W)?\\s*#{AddressExtractor.regExpType(StreetTypes)}"
    intersection = "#{fullStreetName}\\W*((and|n|\\/|\\|\\+|&|&amp;|@)\\W*)+#{fullStreetName}"
    includeBetween = "(#{fullStreetName}\\W*(b.*w.*|bet|bw|b/t|\\s|)\\W*)?#{intersection}"
    address = "\\b(?<!\$)[0-9]+\\W+#{fullProperStreetName}"

    #finalRegExpString = "([^']\\b#{includeBetween}|#{address})\\b"
    finalRegExpString = "(\\b#{includeBetween}|#{address})\\b"
    Regexp.new(finalRegExpString, Regexp::IGNORECASE)
  end

  def self.build_between_regex
    cardinalStreetNames = "(?<!\$)[0-9]+#{AddressExtractor.regExpType(CardinalSuffix)}?"
    allStreetNames = "(#{cardinalStreetNames}|#{AddressExtractor.regExpType(NewYorkStreetNames)})"
    fullStreetName = "(#{AddressExtractor.regExpType(StreetPrefixSuffix)}\\s*)?#{allStreetNames}\\s*(#{AddressExtractor.regExpType(StreetPrefixSuffix)}\\W)?\\s*#{AddressExtractor.regExpType(StreetTypes)}?"
    intersection = "#{fullStreetName}\\W*((and|n|\\/|\\|\\+|&|&amp;|@)\\W*)+#{fullStreetName}"
    includeBetween = "(#{fullStreetName}\\W*(b.*w.*|bet|bw|b/t|\\s|)\\W*)#{intersection}"

    finalRegExpString = "([^']\\b#{includeBetween})\\b"
    Regexp.new(finalRegExpString, Regexp::IGNORECASE)
  end

  def self.clean_address(address)
    return "" if address == nil

    address = address.gsub(/mad\b/i," Madison ")
    address = address.gsub(/lex\b/i," Lexington ")
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

  def self.extract_address(tweet_text)
    match = AddressExtractor.build_regexp.match(tweet_text)
    return "" if match == nil

    address = match[0]
    
    return "" if Regexp.new("[0-9]/[0-9]", Regexp::IGNORECASE).match(address)
    return AddressExtractor.clean_address(address)

  end


  def self.extract_city(tweet_text)
    tweet_text = tweet_text.downcase
    address = ""
    
    if Regexp.new("(^|\\W+)#{AddressExtractor.regExpType(BrooklynNames)}($|\\W+)", Regexp::IGNORECASE).match(tweet_text)
      address = "Brooklyn, NY"
    elsif Regexp.new("(^|\\W+)#{AddressExtractor.regExpType(QueensNames)}($|\\W+)", Regexp::IGNORECASE).match(tweet_text)
      address = "Queens, NY"
    else
address = "New York, NY"
    end

    return address
  end

  def self.geocode_address(address, city_state)
    #puts "GEOCODING:  #{address}, #{city_state}"
    
    return [nil,nil] if address.length == 0
    
    bounds = []
    
    case city_state
    when "New York, NY"
      bounds = [[40.709503,-73.971634],[40.765782,-74.021072]]
    when "Brooklyn, NY"
      bounds = [[40.556714,-73.811989],[40.743217,-74.068108]]
    when "Queens, NY"
      bounds = [[40.546279,-73.665047],[40.804056,-73.998756]]      
    end
    
    if address.include?("between")
    #if Truck.build_between_regexp.match(address)  
      first_street = Regexp.new(".+(?=\\W+between)", Regexp::IGNORECASE).match(address)
      first_cross_street = Regexp.new("(?<=between\\s).+(?=\\sand)", Regexp::IGNORECASE).match(address)
      second_cross_street = Regexp.new("(?<=\\Wand\\W).+", Regexp::IGNORECASE).match(address)
      
      #puts "Between Geocoding: " << address,first_street,first_cross_street,second_cross_street
      
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
      
      #puts first_intersection,second_intersection
      
      if first_geocode[0] != nil && second_geocode[0] != nil
        latitude = (first_geocode[0].coordinates()[0] + second_geocode[0].coordinates()[0])/2 #/
        longitude = (first_geocode[0].coordinates()[1] + second_geocode[0].coordinates()[1])/2 #/
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