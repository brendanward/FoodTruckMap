class Coordinate < ActiveRecord::Base
  validates_uniqueness_of :address
  include RegexpBuilder
  
  def geocode_address
    address = self.address.partition(/,[^,]+,\s\S{2}\z/i) [0]
    city_state = self.address.match(/[^,]+,\s\S{2}\z/i) [0].strip!
    
    bounds = []
    
    case city_state
    when "New York, NY"
      bounds = [[40.709503,-73.971634],[40.765782,-74.021072]]
    when "Brooklyn, NY"
      bounds = [[40.556714,-73.811989],[40.743217,-74.068108]]
    when "Queens, NY"
      bounds = [[40.546279,-73.665047],[40.804056,-73.998756]]      
    end
    
    unless get_regexp(include_between).match(address).nil? || !get_regexp(street_address).match(address).nil?
      first_street = get_regexp(between_address_first_part).match(address)
      intersection_text = get_regexp(intersection).match(address)
      unless intersection_text.nil? 
        first_cross_street = get_regexp(intersection_first_street).match(intersection_text[0])
        second_cross_street = get_regexp(intersection_second_street).match(intersection_text[0])
      end
      
      return if first_street.nil? || first_cross_street.nil? || second_cross_street.nil?
      
      first_intersection = first_street[0] + " and " + first_cross_street[0] + ", " + city_state
      second_intersection = first_street[0] + " and " + second_cross_street[0] + ", " + city_state
      
      first_geocode = Geocoder.search(first_intersection, :bounds => bounds)
      second_geocode = Geocoder.search(second_intersection, :bounds => bounds)
      
      unless first_geocode[0].nil? || second_geocode[0].nil?
        self.latitude = (first_geocode[0].coordinates()[0] + second_geocode[0].coordinates()[0])/2 #/
        self.longitude = (first_geocode[0].coordinates()[1] + second_geocode[0].coordinates()[1])/2 #/
      end
    else
      geocode = Geocoder.search(self.address, :bounds => bounds)
      
      unless geocode[0].nil? 
        self.latitude = geocode[0].coordinates()[0]
        self.longitude = geocode[0].coordinates()[1]
      end
    end
    
  end
end
