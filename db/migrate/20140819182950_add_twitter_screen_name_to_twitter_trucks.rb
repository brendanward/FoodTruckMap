class AddTwitterScreenNameToTwitterTrucks < ActiveRecord::Migration
  def change
    add_column :twitter_trucks, :twitter_screen_name, :string
  end
end
