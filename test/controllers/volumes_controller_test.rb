require 'test_helper'

class VolumesControllerTest < ActionDispatch::IntegrationTest
  test "should get list" do
    get volumes_list_url
    assert_response :success
  end

  test "should get view" do
    get volumes_view_url
    assert_response :success
  end

end
