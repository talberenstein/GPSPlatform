class CouplesTypesController < ApplicationController
  before_action :set_couples_type, only: [:update, :destroy]

  # POST /couples_types
  # POST /couples_types.json
  def create
    @couples_type = CouplesType.new(couples_type_params)
    respond_to do |format|
      if @couples_type.save
        format.js {}
      else
        format.js {}
      end
    end
  end

  # PATCH/PUT /couples_types/1
  # PATCH/PUT /couples_types/1.json
  def update
    respond_to do |format|
      if @couples_type.update(couples_type_params)
        format.js {}
      else
        format.js {}
      end
    end
  end

  # DELETE /couples_types/1
  # DELETE /couples_types/1.json
  def destroy
    @couples_type.destroy
    respond_to do |format|
      format.js {}
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_couples_type
    @couples_type = CouplesType.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def couples_type_params
    params.require(:couples_type).permit(:couple_name, :high, :width, :long, :weight )
  end
end
