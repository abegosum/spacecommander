require 'test_helper'

class PhysicalManagersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get physical_managers_index_url
    assert_response :success
  end

  test "should get show" do
    get physical_managers_show_url
    assert_response :success
  end

end
