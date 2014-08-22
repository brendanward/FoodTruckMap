class TweetsController < ApplicationController
  before_action :set_tweet, only: [:show]
  
  def show
    @coordinate = Coordinate.find_by address: @tweet.extract_full_address
  end
  
   private
    # Use callbacks to share common setup or constraints between actions.
    def set_tweet
      @tweet = Tweet.find(params[:id])
    end
end
