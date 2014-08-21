class TwitterTruck < ActiveRecord::Base
  include TwitterAccessor
  
  @@last_updated = nil
  
  def self.update_trucks
    if @@last_updated.nil? || (Time.now - @@last_updated) > (60 * 60)
      @@last_updated = Time.now      

      trucks = get_list_members

      trucks.each do |truck|
        truck_id = truck.id
        twitter_trucks = TwitterTruck.where("twitter_user_id = #{truck_id}")
        twitter_truck = twitter_trucks[0]
        
        if twitter_truck.nil?
          twitter_truck = TwitterTruck.new
          twitter_truck.twitter_user_id = truck.id
        end

        twitter_truck.name = truck.name
        twitter_truck.twitter_screen_name = truck.screen_name
        twitter_truck.image_url = truck.profile_image_url(size = :normal).to_s
        twitter_truck.save
      end
    end

    return trucks
  end
  
  def get_timeline_since(date)
    get_timeline_for_user_since(self.twitter_user_id,date)
  end

end
