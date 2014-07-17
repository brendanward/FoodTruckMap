class CreateTrucks < ActiveRecord::Migration
  def change
    create_table :trucks do |t|
      t.string :name
      t.string :twitter_user_name
      t.float :latitude
      t.float :longitude
      t.string :address

      t.timestamps
    end
  end
end
