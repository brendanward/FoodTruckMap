class TweetsController < ApplicationController
  before_action :set_tweet, only: [:show]
  
  def show
  end
  
   private
    # Use callbacks to share common setup or constraints between actions.
    def set_tweet
      @tweet = Tweet.find(params[:id])
    end
end
