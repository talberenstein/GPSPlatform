class GeoZonesController < ApplicationController
  before_action :set_geo_zone, only: [:update, :destroy]

  def index
    @geo_zones = current_user.global_admin? ? GeoZone.all : current_user.company.geo_zones
  end

  # POST /geo_zones
  # POST /geo_zones.json
  def create
    data = geo_zone_params

    puts '----'
    puts 'name: ' +data[:company_id]
    puts 'panic: ' +data[:panic]
    puts '----'

    data[:geom] = RGeo::GeoJSON.decode(JSON.parse ( data[:geom] ), json_parser: :json).geometry

    puts '+++++'
    puts '+++++'

    @geo_zone = GeoZone.new(data)
    @geo_zone.company_id = current_user.company_id unless current_user.global_admin?
    @geo_zone.is_display = 'TRUE'


    respond_to do |format|
      if @geo_zone.save
        format.js {
        }
      else
        format.js {}
      end
    end
  end

  # PATCH/PUT /geo_zones/1
  # PATCH/PUT /geo_zones/1.json
  def update
    data = geo_zone_params
    puts '----'
    puts data[:geom]
    puts '----'
    #if data[:edit_polygon] == 'on'
      puts 'TRUE edit_polygon'
    data[:geom] = (JSON.parse ( data[:geom] ), json_parser: :json)['geometry']
    puts data[:geom]
    asdf = RGeo::GeoJSON.decode(data[:geom], json_parser: :json)
    #end
    puts '+++++'
    puts asdf
    puts data[:geom].inspect
    puts '+++++'

    respond_to do |format|
      if @geo_zone.update(data)
        format.js {}
      else
        format.js {}
      end
    end
  end

  # DELETE /geo_zones/1
  # DELETE /geo_zones/1.json
  def destroy
    @geo_zone.destroy
    respond_to do |format|
      format.js {}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_geo_zone
      @geo_zone = GeoZone.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def geo_zone_params
      if current_user.global_admin?
        params.require(:geo_zone).permit(:name, :enter_alert, :exit_alert, :send_report, :panic, :low_battery, :shutdown, :restart_on, :ignicion, :c_open, :c_closed, :desenganche, :cg_open, :cg_closed, :stop_report, :excess_limit, :end_excess_limit, :geom, :company_id)
      else
        params.require(:geo_zone).permit(:name, :enter_alert, :exit_alert, :send_report, :panic, :low_battery, :shutdown, :restart_on, :ignicion, :c_open, :c_closed, :desenganche, :cg_open, :cg_closed, :stop_report, :excess_limit, :end_excess_limit, :geom)
      end
    end
end
