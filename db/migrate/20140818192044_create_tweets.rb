class CreateTweets < ActiveRecord::Migration
  def change
    create_table(:tweets) do |t|
      t.integer :twitter_id, :limit => 8, :null => false
      t.integer :twitter_user_id
      t.string :text
      t.datetime :tweet_created_at

      t.timestamps
    end
  end
end
