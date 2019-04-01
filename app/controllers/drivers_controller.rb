class DriversController < ApplicationController
  before_action :set_driver, only: [:update, :destroy]

  # POST /drivers
  # POST /drivers.json
  def create
    @driver = Driver.new(driver_params)
    @driver.company_id = current_user.company_id unless current_user.global_admin?

    respond_to do |format|
      if @driver.save
        format.js {}
      else
        format.js {}
      end
    end
  end

  # PATCH/PUT /drivers/1
  # PATCH/PUT /drivers/1.json
  def update
    respond_to do |format|
      if @driver.update(driver_params)
        format.js {}
      else
        format.js {}
      end
    end
  end

  # DELETE /drivers/1
  # DELETE /drivers/1.json
  def destroy
    @driver.destroy
    respond_to do |format|
      format.js {}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_driver
      @driver = Driver.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def driver_params
      if current_user.global_admin?
        params.require(:driver).permit(:name, :rut, :company_id)
      else
        params.require(:driver).permit(:name, :rut)
      end
    end
end
