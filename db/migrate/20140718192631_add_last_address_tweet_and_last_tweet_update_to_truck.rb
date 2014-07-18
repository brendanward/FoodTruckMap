class AddLastAddressTweetAndLastTweetUpdateToTruck < ActiveRecord::Migration
  def change
    add_column :trucks, :last_address_tweet, :string
    add_column :trucks, :last_address_update, :datetime
  end
end
