require 'test_helper'

class EnvironmentControllerTest < ActionDispatch::IntegrationTest
  test "should get refresh" do
    get environment_refresh_url
    assert_response :success
  end

end
