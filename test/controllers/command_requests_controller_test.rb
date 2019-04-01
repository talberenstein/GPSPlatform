require 'test_helper'

class CommandRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @command_request = command_requests(:one)
  end

  test "should get index" do
    get command_requests_url
    assert_response :success
  end

  test "should get new" do
    get new_command_request_url
    assert_response :success
  end

  test "should create command_request" do
    assert_difference('CommandRequest.count') do
      post command_requests_url, params: { command_request: { command_text: @command_request.command_text, request_time: @command_request.request_time, result_time: @command_request.result_time, status: @command_request.status, user_id: @command_request.user_id } }
    end

    assert_redirected_to command_request_url(CommandRequest.last)
  end

  test "should show command_request" do
    get command_request_url(@command_request)
    assert_response :success
  end

  test "should get edit" do
    get edit_command_request_url(@command_request)
    assert_response :success
  end

  test "should update command_request" do
    patch command_request_url(@command_request), params: { command_request: { command_text: @command_request.command_text, request_time: @command_request.request_time, result_time: @command_request.result_time, status: @command_request.status, user_id: @command_request.user_id } }
    assert_redirected_to command_request_url(@command_request)
  end

  test "should destroy command_request" do
    assert_difference('CommandRequest.count', -1) do
      delete command_request_url(@command_request)
    end

    assert_redirected_to command_requests_url
  end
end
