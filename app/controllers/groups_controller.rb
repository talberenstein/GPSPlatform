class GroupsController < ApplicationController
  before_action :set_group, only: [:update, :destroy]

  def index
    render json: Company.find(params.permit(:company_id)["company_id"]).groups.pluck(:id, :name).to_json
  end


  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)
    @group.company_id = current_user.company_id unless current_user.global_admin?

    respond_to do |format|
      if @group.save
        format.js {}
      else
        format.js {}
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.js {}
      else
        format.js {}
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.js {}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      if current_user.global_admin?
        params.require(:group).permit(:name, :company_id)
      else
        params.require(:group).permit(:name)
      end
    end
end
