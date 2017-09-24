require 'test_helper'

class FilersControllerTest < ActionDispatch::IntegrationTest
  test "should get list" do
    get filers_list_url
    assert_response :success
  end

  test "should get view" do
    get filers_view_url
    assert_response :success
  end

end
