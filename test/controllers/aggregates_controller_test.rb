require 'test_helper'

class AggregatesControllerTest < ActionDispatch::IntegrationTest
  test "should get list" do
    get aggregates_list_url
    assert_response :success
  end

  test "should get view" do
    get aggregates_view_url
    assert_response :success
  end

end
