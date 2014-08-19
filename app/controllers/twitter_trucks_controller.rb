class TwitterTrucksController < ApplicationController
  before_action :set_twitter_truck, only: [:show, :edit, :update, :destroy]

  # GET /twitter_trucks
  # GET /twitter_trucks.json
  def index
    TwitterTruck.update_trucks
    Tweet.update_tweets
    
    truck_tweets = Hash.new
    current_date = DateTime.now.in_time_zone("EST").beginning_of_day
    
    tweets = Tweet.where("tweet_created_at >= '#{current_date.to_s}'").order(tweet_created_at: :desc)
    
    tweets.each { |tweet| truck_tweets[tweet.twitter_user_id] = tweet if !truck_tweets[tweet.twitter_user_id] && tweet.contains_address? }
    
    @trucks_without_location = []
    @all_trucks = Hash.new
    
    TwitterTruck.all.each do |truck|
      @all_trucks[truck.twitter_user_id] = truck
      @trucks_without_location << truck if !truck_tweets[truck.twitter_user_id]
    end
    
    @hash = Gmaps4rails.build_markers(truck_tweets.values) do |tweet, marker|
      coordinates = tweet.get_coordinates
      sleep(1.0/16.0) #/
      
      if coordinates[0] != nil and coordinates[1] != nil
        marker.lat coordinates[0]
        marker.lng coordinates[1]
        marker.infowindow render_to_string(:partial => "/twitter_trucks/infowindow", :locals => { :tweet => tweet})
        marker.picture({
          "url" => @all_trucks[tweet.twitter_user_id].image_url,
                       "width" =>  40,
                       "height" => 40})
      end
    end
  end

  # GET /twitter_trucks/1
  # GET /twitter_trucks/1.json
  def show
  end

  # GET /twitter_trucks/new
  def new
    @twitter_truck = TwitterTruck.new
  end

  # GET /twitter_trucks/1/edit
  def edit
  end

  # POST /twitter_trucks
  # POST /twitter_trucks.json
  def create
    @twitter_truck = TwitterTruck.new(twitter_truck_params)

    respond_to do |format|
      if @twitter_truck.save
        format.html { redirect_to @twitter_truck, notice: 'Twitter truck was successfully created.' }
        format.json { render :show, status: :created, location: @twitter_truck }
      else
        format.html { render :new }
        format.json { render json: @twitter_truck.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /twitter_trucks/1
  # PATCH/PUT /twitter_trucks/1.json
  def update
    respond_to do |format|
      if @twitter_truck.update(twitter_truck_params)
        format.html { redirect_to @twitter_truck, notice: 'Twitter truck was successfully updated.' }
        format.json { render :show, status: :ok, location: @twitter_truck }
      else
        format.html { render :edit }
        format.json { render json: @twitter_truck.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /twitter_trucks/1
  # DELETE /twitter_trucks/1.json
  def destroy
    @twitter_truck.destroy
    respond_to do |format|
      format.html { redirect_to twitter_trucks_url, notice: 'Twitter truck was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_twitter_truck
      @twitter_truck = TwitterTruck.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def twitter_truck_params
      params.require(:twitter_truck).permit(:twitter_user_id, :name, :image_url)
    end
end
