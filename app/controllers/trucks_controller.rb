class TrucksController < ApplicationController
  before_action :set_truck, only: [:show, :edit, :update, :destroy]

  # GET /trucks
  # GET /trucks.json
  def index
    @trucks = Truck.all
    
    for truck in @trucks
        truck.geocode_truck
    end
    
    @trucks = Truck.all
    
    @hash = Gmaps4rails.build_markers(@trucks) do |truck, marker|
      if truck.latitude != nil and truck.longitude != nil
        marker.lat truck.latitude
        marker.lng truck.longitude
        marker.infowindow render_to_string(:partial => "/trucks/infowindow", :locals => { :truck => truck})
        #marker.infowindow truck.get_profile_image
        marker.picture({
                       "url" => truck.get_profile_image,
                       "width" =>  40,
                       "height" => 40})
      end
    end
  end
  
  def history
    @trucks = Truck.all
    
    @past_locations = Array.new
    
    for truck in @trucks
      @past_locations = @past_locations.concat(truck.get_past_locations)
    end
    
    @hash = Gmaps4rails.build_markers(@past_locations) do |past_location, marker|
      if past_location.latitude != nil and past_location.longitude != nil
        marker.lat past_location.latitude
        marker.lng past_location.longitude
        marker.infowindow render_to_string(:partial => "/trucks/pastlocationinfowindow", :locals => { :past_location => past_location })
      end
    end
  end
    
    

  # GET /trucks/1
  # GET /trucks/1.json
  def show
    truck = Truck.find(params[:id])
    
    @past_locations = truck.get_past_locations
    
    @hash = Gmaps4rails.build_markers(@past_locations) do |past_location, marker|
      if past_location.latitude != nil and past_location.longitude != nil
        marker.lat past_location.latitude
        marker.lng past_location.longitude
        marker.infowindow render_to_string(:partial => "/trucks/pastlocationinfowindow", :locals => { :past_location => past_location})
      end
    end
    
  end

  # GET /trucks/new
  def new
    @truck = Truck.new
  end

  # GET /trucks/1/edit
  def edit
  end

  # POST /trucks
  # POST /trucks.json
  def create
    @truck = Truck.new(truck_params)

    respond_to do |format|
      if @truck.save
        format.html { redirect_to @truck, notice: 'Truck was successfully created.' }
        format.json { render :show, status: :created, location: @truck }
      else
        format.html { render :new }
        format.json { render json: @truck.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trucks/1
  # PATCH/PUT /trucks/1.json
  def update
    respond_to do |format|
      if @truck.update(truck_params)
        format.html { redirect_to @truck, notice: 'Truck was successfully updated.' }
        format.json { render :show, status: :ok, location: @truck }
      else
        format.html { render :edit }
        format.json { render json: @truck.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trucks/1
  # DELETE /trucks/1.json
  def destroy
    @truck.destroy
    respond_to do |format|
      format.html { redirect_to trucks_url, notice: 'Truck was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_truck
      @truck = Truck.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def truck_params
      params.require(:truck).permit(:name, :twitter_user_name, :latitude, :longitude, :address)
    end
end
