class AlertsController < ApplicationController
    def seen
        id = params[:id]
        alerts = current_user.global_admin? ? Alert : current_user.company.alerts 
        alerts.update id, seen: true

        head :no_content
    end

    def index
        #@alerts = current_user.global_admin ? Alert : current_user.company.alerts

        #render json: @alerts
    end


end
