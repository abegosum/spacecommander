require 'test_helper'

class DebugControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get debug_show_url
    assert_response :success
  end

end
