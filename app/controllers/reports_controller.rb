class ReportsController < ApplicationController
  before_filter :set_dates, except: [:speeds_graph, :stops_graph]

  def speeds
    @velocity_limit = params[:velocity_limit].to_f
    imeis = params[:imeis]
    
    @excesses = {}

    exceeded_frames = (current_user.global_admin? ? Frame : current_user.company.frames).valid.position.between_dates(@from, @to).from_imei(imeis).ordered.velocity_gt(@velocity_limit)
    imeis = exceeded_frames.map{|f| f.imei}.uniq
    all_frames = (current_user.global_admin? ? Frame : current_user.company.frames).valid.position.between_dates(@from, @to).ordered.from_imei(imeis)

    imeis.each do |imei|
      starting_time = @from.beginning_of_day
      @excesses[imei] = {excesses: []}
      
      while true
        start_of_exceed = exceeded_frames.from_imei(imei).gps_date_gt(starting_time).first
        break unless start_of_exceed
        end_of_exceed = all_frames.from_imei(imei).gps_date_gt(start_of_exceed.gps_date).velocity_lte(@velocity_limit).first
        break unless end_of_exceed

        frames = exceeded_frames.from_imei(imei).between_dates(start_of_exceed.gps_date, end_of_exceed.gps_date)
        starting_time = end_of_exceed.gps_date
        @excesses[imei][:excesses] << {start_of_exceed: start_of_exceed, end_of_exceed: end_of_exceed, max_velocity: frames.maximum(:velocity)}   
      end
    end

    respond_to do |format|
      format.html
      format.xlsx{ response.headers['Content-Disposition'] = "attachment; filename=\"Reporte de Velocidades desde #{l(@from, format: :short)} hasta #{l(@to, format: :short)} limite de velocidad #{@velocity_limit.round} km-h.xlsx\"" }
    end   
  end

  def stops
    @time_limit = params[:time_limit].to_f
    imeis = params[:imeis]

    @stops = {}
    stop_frames = (current_user.global_admin? ? Frame : current_user.company.frames).valid.position.between_dates(@from, @to).from_imei(imeis).ordered.velocity_lte(5)
    imeis = stop_frames.map{|f| f.imei}.uniq
    all_frames = (current_user.global_admin? ? Frame : current_user.company.frames).valid.position.between_dates(@from, @to).ordered.from_imei(imeis)

    imeis.each do |imei|
      starting_time = @from.beginning_of_day
      @stops[imei] = {stops: []}
      
      while true
        start_of_stop = stop_frames.from_imei(imei).gps_date_gt(starting_time).first
        break unless start_of_stop
        end_of_stop = all_frames.from_imei(imei).gps_date_gt(start_of_stop.gps_date).velocity_gt(5).first
        break unless end_of_stop

        starting_time = end_of_stop.gps_date
        @stops[imei][:stops] << {start_of_stop: start_of_stop, end_of_stop: end_of_stop} if TimeDifference.between(end_of_stop.gps_date, start_of_stop.gps_date).in_minutes > @time_limit   
      end
    end

    respond_to do |format|
      format.html
      format.xlsx{ response.headers['Content-Disposition'] = "attachment; filename=\"Reporte de Detenciones desde #{l(@from, format: :short)} hasta #{l(@to, format: :short)} limite de tiempo #{@time_limit.round} minutos.xlsx\"" }
    end 
  end

  def path
    imei = params[:imei]
    frames = (current_user.global_admin? ? Frame : current_user.company.frames).valid.position.between_dates(@from, @to).ordered.from_imei(imei)
    @points = {
      type: "Feature",
        geometry: {
          type: "MultiPoint",
          coordinates: []
        },
        properties: {
          time: [],
          speed: [],
          altitude: [],
          heading: [],
          path_options: {
            color: 'blue'
          }
        }
    }
    
    frames.each do |frame|
      @points[:properties][:icon] ||= frame.device_type   
      @points[:geometry][:coordinates] << frame.geom.coordinates
      @points[:properties][:time] << frame.gps_date.to_f * 1000
      @points[:properties][:speed] << frame.velocity
      @points[:properties][:altitude] << frame.altitude
      @points[:properties][:heading] << frame.direction || 0
    end
  end

  def daily_activities
    @da = {}
    imeis = params[:imeis]
    frames = (current_user.global_admin? ? Frame : current_user.company.frames).valid.between_dates(@from.beginning_of_day, @to.end_of_day).ordered.from_imei(imeis)
    imeis = frames.map{|f| f.imei}.uniq
    imeis.each do |imei|
      @da[imei] ||= {
        activities: []
      }
      (@from.to_date..@to.to_date).each do |day|
        day_frames = frames.between_dates(day.beginning_of_day, day.end_of_day).from_imei(imei)
        next unless day_frames.any?
        distance = 0
        drive_hours = 0
        stopoff_hours = 0
        day_frames.each do |df|
          prev_frame = day_frames.gps_date_lt(df.gps_date).last
          next unless prev_frame
          distance += distance_gps(prev_frame.geom.coordinates.reverse, df.geom.coordinates.reverse)
          drive_hours += TimeDifference.between(df.gps_date, prev_frame.gps_date).in_hours if df.velocity > 5
          stopoff_hours += TimeDifference.between(df.gps_date, prev_frame.gps_date).in_hours if df.velocity <= 5 and df.ignition
        end
        @da[imei][:activities] << {
            date: day,
            distance: (distance / 1000).round(1),
            trips: day_frames.ignition_on.count,
            drive_hours: drive_hours.round,
            stopoff_hours: 24 - drive_hours.round,
            stopon_hours: stopoff_hours.round,
        }
      end 
    end

    respond_to do |format|
      format.html
      format.xlsx{ response.headers['Content-Disposition'] = "attachment; filename=\"Reporte de Actividades Diarias desde #{l(@from, format: :short)} hasta #{l(@to, format: :short)}.xlsx\"" }
    end 
  end

  def geo_zones_histories
    imeis = params[:imeis]
    @geo_zones_histories = (current_user.global_admin? ? GeoZoneHistory : current_user.company.geo_zones_histories).ordered.between_dates(@from, @to).from_imei(imeis)

    respond_to do |format|
      format.html
      format.xlsx{ response.headers['Content-Disposition'] = "attachment; filename=\"Reporte de Geo Zonas desde #{l(@from, format: :short)} hasta #{l(@to, format: :short)}.xlsx\"" }
    end 
  end

  def speeds_graph
    imei = params[:imei]
    start_of_exceed = Time.parse params[:start_of_exceed]
    end_of_exceed = Time.parse params[:end_of_exceed]
    frames = Frame.from_imei(imei).valid.between_dates(start_of_exceed, end_of_exceed).ordered
    
    @speeds_graph_points = {
      type: "Feature",
      geometry: {
        type: "MultiPoint",
        coordinates: []
      },
      properties: {
        time: [],
        speed: [],
        altitude: [],
        heading: [],
        path_options: {
          color: 'blue'
        }
      }     
    }

    frames.each do |frame|
      @speeds_graph_points[:properties][:icon] ||= frame.device_type   
      @speeds_graph_points[:geometry][:coordinates] << frame.geom.coordinates
      @speeds_graph_points[:properties][:time] << frame.gps_date.to_f * 1000
      @speeds_graph_points[:properties][:speed] << frame.velocity
      @speeds_graph_points[:properties][:altitude] << frame.altitude
      @speeds_graph_points[:properties][:heading] << frame.direction || 0
    end
  end

  def stops_graph
    @position = params[:stop].map{|p| p.to_f}
  end

  private
  def set_dates
    @from = Time.parse("#{params[:from_date]} #{params[:from_time]}")
    @to = Time.parse("#{params[:to_date]} #{params[:to_time]}")
  end
end
