class DevicesController < ApplicationController
  before_action :set_device, only: [:update, :destroy]

  # POST /devices
  # POST /devices.json
  def create
    @device = Device.new(device_params)
    @device.company_id = current_user.company_id unless current_user.global_admin?

    respond_to do |format|
      if @device.save
        format.js {}
      else
        format.js {}
      end
    end
  end

  # PATCH/PUT /devices/1
  # PATCH/PUT /devices/1.json
  def update
    puts 'entre al update_devices'
    respond_to do |format|
      if @device.update(device_params)
        format.js {}
      else
        format.js {}
      end
    end
  end

  # DELETE /devices/1
  # DELETE /devices/1.json
  def destroy
    @device.destroy
    respond_to do |format|
      format.js {}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      puts 'Entre al set_devices'
      @device = Device.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_params
      if current_user.global_admin?
        params.require(:device).permit(:name, :icon, :imei, :phone, :company_id, :driver_id, :group_id)
      else
        params.require(:device).permit(:name, :icon, :phone, :driver_id, :group_id)
      end
    end
end
