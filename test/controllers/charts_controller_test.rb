require 'test_helper'

class ChartsControllerTest < ActionDispatch::IntegrationTest
  test "should get node_physical_show" do
    get charts_node_physical_show_url
    assert_response :success
  end

  test "should get filer_virtual_show" do
    get charts_filer_virtual_show_url
    assert_response :success
  end

end
