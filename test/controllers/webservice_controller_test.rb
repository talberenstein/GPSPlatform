require 'test_helper'

class WebserviceControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get webservice_index_url
    assert_response :success
  end

end
