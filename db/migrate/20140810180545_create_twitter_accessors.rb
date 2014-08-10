class CreateTwitterAccessors < ActiveRecord::Migration
  def change
    create_table :twitter_accessors do |t|

      t.timestamps
    end
  end
end
