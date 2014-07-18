class AddLastAddressTweetTimeToTrucks < ActiveRecord::Migration
  def change
    add_column :trucks, :last_address_tweet_time, :datetime
  end
end
