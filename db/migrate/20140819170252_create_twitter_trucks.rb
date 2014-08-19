class CreateTwitterTrucks < ActiveRecord::Migration
  def change
    create_table :twitter_trucks do |t|
      t.integer :twitter_user_id
      t.string :name
      t.string :image_url

      t.timestamps
    end
  end
end
