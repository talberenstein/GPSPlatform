json.extract! command_request, :id, :user_id, :request_time, :command_text, :status, :result_time, :created_at, :updated_at
json.url command_request_url(command_request, format: :json)