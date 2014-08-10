require 'test_helper'

class TwitterAccessorsControllerTest < ActionController::TestCase
  setup do
    @twitter_accessor = twitter_accessors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:twitter_accessors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create twitter_accessor" do
    assert_difference('TwitterAccessor.count') do
      post :create, twitter_accessor: {  }
    end

    assert_redirected_to twitter_accessor_path(assigns(:twitter_accessor))
  end

  test "should show twitter_accessor" do
    get :show, id: @twitter_accessor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @twitter_accessor
    assert_response :success
  end

  test "should update twitter_accessor" do
    patch :update, id: @twitter_accessor, twitter_accessor: {  }
    assert_redirected_to twitter_accessor_path(assigns(:twitter_accessor))
  end

  test "should destroy twitter_accessor" do
    assert_difference('TwitterAccessor.count', -1) do
      delete :destroy, id: @twitter_accessor
    end

    assert_redirected_to twitter_accessors_path
  end
end
