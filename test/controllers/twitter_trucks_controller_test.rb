require 'test_helper'

class TwitterTrucksControllerTest < ActionController::TestCase
  setup do
    @twitter_truck = twitter_trucks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:twitter_trucks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create twitter_truck" do
    assert_difference('TwitterTruck.count') do
      post :create, twitter_truck: { image_path: @twitter_truck.image_path, twitter_use_id: @twitter_truck.twitter_use_id, user_name: @twitter_truck.user_name }
    end

    assert_redirected_to twitter_truck_path(assigns(:twitter_truck))
  end

  test "should show twitter_truck" do
    get :show, id: @twitter_truck
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @twitter_truck
    assert_response :success
  end

  test "should update twitter_truck" do
    patch :update, id: @twitter_truck, twitter_truck: { image_path: @twitter_truck.image_path, twitter_use_id: @twitter_truck.twitter_use_id, user_name: @twitter_truck.user_name }
    assert_redirected_to twitter_truck_path(assigns(:twitter_truck))
  end

  test "should destroy twitter_truck" do
    assert_difference('TwitterTruck.count', -1) do
      delete :destroy, id: @twitter_truck
    end

    assert_redirected_to twitter_trucks_path
  end
end
