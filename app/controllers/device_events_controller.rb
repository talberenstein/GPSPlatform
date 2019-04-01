class DeviceEventsController < ApplicationController
  before_action :set_device_event, only: [:update, :destroy]

  # POST /device_events
  # POST /device_events.json
  def create
    @device_event = DeviceEvent.new(device_event_params)

    respond_to do |format|
      if @device_event.save
        format.js {}
      else
        format.js {}
      end
    end
  end

  # PATCH/PUT /device_events/1
  # PATCH/PUT /device_events/1.json
  def update
    @device_event.company_id = current_user.global_admin? ? @device_event.device.company_id : current_user.company_id
    respond_to do |format|
      if @device_event.update(device_event_params)
        format.js {}
      else
        format.js {}
      end
    end
  end

  # DELETE /device_events/1
  # DELETE /device_events/1.json
  def destroy
    @device_event.destroy
    respond_to do |format|
      format.js {}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device_event
      @device_event = DeviceEvent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_event_params
      params.require(:device_event).permit(:device_id, event_ids: [])
    end
end
