require 'test_helper'

class TestControllerTest < ActionDispatch::IntegrationTest
  test "should get view" do
    get test_view_url
    assert_response :success
  end

end
