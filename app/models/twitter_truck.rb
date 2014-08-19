class TwitterTruck < ActiveRecord::Base
  include TwitterAccessor
  
  def self.update_trucks
    min_updated_at = TwitterTruck.minimum(:updated_at)
    
    if min_updated_at == nil || (Time.now - min_updated_at) > 1 #(60 * 60 * 12)      
      #client = configure_twitter
      #trucks = client.list_members(:slug=>"foodtrucks")
      trucks = get_list_members

      trucks.each do |truck|
        truck_id = truck.id
        twitter_trucks = TwitterTruck.where("twitter_user_id = #{truck_id}")
        twitter_truck = twitter_trucks[0]
        
        if twitter_truck == nil
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

end
