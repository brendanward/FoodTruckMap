class FixTrucksProfileUrlColumnNames < ActiveRecord::Migration
  def change
    rename_column :trucks, :profil_image_url, :profile_image_url
    rename_column :trucks, :profile_image_last_updated, :profile_image_url_last_updated
  end
end
