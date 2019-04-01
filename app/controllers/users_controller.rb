class UsersController < ApplicationController
  before_action :set_user, only: [:update, :destroy]

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.company_id = current_user.company_id unless current_user.global_admin?
    respond_to do |format|
      if @user.save
        format.js {}
      else
        format.js {}
      end
    end
  end


  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update_without_password(user_params)
        format.js {}
      else
        format.js {}
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.js {}
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])

  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    puts 'PARAMS'
    puts params.inspect


    if current_user.global_admin?
      params.require(:user).permit(:email, :password, :password_confirmation,
                                   :role, :company_id, :send_command,
                                   group_ids: [])
    else
      params.require(:user).permit(:email, :password, :password_confirmation, :role, :group_id)
    end
  end
end
