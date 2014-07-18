class AddImageUrlToTruck < ActiveRecord::Migration
  def change
    add_column :trucks, :profil_image_url, :string
    add_column :trucks, :profile_image_last_updated, :datetime
  end
end
