class TwitterAccessorsController < ApplicationController
  before_action :set_twitter_accessor, only: [:show, :edit, :update, :destroy]

  # GET /twitter_accessors
  # GET /twitter_accessors.json
  def index 
    TwitterAccessor.update_tweets
    truck_tweets = TwitterAccessor.get_tweet_for_each_truck
    @trucks_without_location = []
    @all_trucks = Hash.new
    
    TwitterAccessor.get_all_trucks.each do |truck|
      @all_trucks[truck.id] = truck
      if truck_tweets[truck.id] == nil
        @trucks_without_location << truck
      end
    end
    
    @hash = Gmaps4rails.build_markers(truck_tweets.values) do |tweet, marker|
      address = AddressExtractor.extract_address(tweet.text)
      city = AddressExtractor.extract_city(tweet.text)
      coordinates = AddressExtractor.geocode_address(address,city)
      sleep(1.0/8.0) #/
      
      if coordinates[0] != nil and coordinates[1] != nil
        marker.lat coordinates[0]
        marker.lng coordinates[1]
        marker.infowindow render_to_string(:partial => "/twitter_accessors/infowindow", :locals => { :tweet => tweet})
        marker.picture({
          "url" => @all_trucks[tweet.twitter_user_id].profile_image_url(size = :normal).to_s,
                       "width" =>  40,
                       "height" => 40})
      end
    end
  end

  # GET /twitter_accessors/1
  # GET /twitter_accessors/1.json
  def show
  end

  # GET /twitter_accessors/new
  def new
    @twitter_accessor = TwitterAccessor.new
  end

  # GET /twitter_accessors/1/edit
  def edit
  end

  # POST /twitter_accessors
  # POST /twitter_accessors.json
  def create
    @twitter_accessor = TwitterAccessor.new(twitter_accessor_params)

    respond_to do |format|
      if @twitter_accessor.save
        format.html { redirect_to @twitter_accessor, notice: 'Twitter accessor was successfully created.' }
        format.json { render :show, status: :created, location: @twitter_accessor }
      else
        format.html { render :new }
        format.json { render json: @twitter_accessor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /twitter_accessors/1
  # PATCH/PUT /twitter_accessors/1.json
  def update
    respond_to do |format|
      if @twitter_accessor.update(twitter_accessor_params)
        format.html { redirect_to @twitter_accessor, notice: 'Twitter accessor was successfully updated.' }
        format.json { render :show, status: :ok, location: @twitter_accessor }
      else
        format.html { render :edit }
        format.json { render json: @twitter_accessor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /twitter_accessors/1
  # DELETE /twitter_accessors/1.json
  def destroy
    @twitter_accessor.destroy
    respond_to do |format|
      format.html { redirect_to twitter_accessors_url, notice: 'Twitter accessor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_twitter_accessor
      @twitter_accessor = TwitterAccessor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def twitter_accessor_params
      params[:twitter_accessor]
    end
end
