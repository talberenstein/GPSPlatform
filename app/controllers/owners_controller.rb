class OwnersController < ApplicationController
  before_action :set_owner, only: [:update, :destroy]

  # POST /owners
  # POST /owners.json
  def create
    @owner = Owner.new(owner_params)
    puts owner_params
    respond_to do |format|
      if @owner.save
        format.js {}
      else
        format.js {}
      end
    end
  end

  # PATCH/PUT /owners/1
  # PATCH/PUT /owners/1.json
  def update
    respond_to do |format|
      if @owner.update(owner_params)
        format.js {}
      else
        format.js {}
      end
    end
  end

  # DELETE /owners/1
  # DELETE /owners/1.json
  def destroy
    @owner.destroy
    respond_to do |format|
      format.js {}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_owner
      @owner = Owner.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def owner_params
      params.require(:owner).permit(:owner_name, :location_id)
    end
end
