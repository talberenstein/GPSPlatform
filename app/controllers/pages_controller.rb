class PagesController < ApplicationController
  def index
    if current_user.global_admin?
      @devices = Device.includes([:company, :driver, :group])
      @events  = Event.all
      @drivers = Driver.includes(:company)
      @groups  = Group.includes([:company, { devices: :last_position_frame }])
      @companies = Company.all
      @users   = User.includes(:company)
      @device_events = DeviceEvent.includes([:device, :event])
      @geo_zones = GeoZone.all
      @locations = Location.display
    else
      @devices = current_user.company.devices.includes([:company, :driver, :group])
      @drivers = current_user.company.drivers.includes(:company)
      @groups  = current_user.company.groups.includes([:company, { devices: :last_position_frame }])
      @companies = current_user.company
      @users   = current_user.company.users
      @device_events = current_user.company.device_events.includes([:device, :event])
      @geo_zones = current_user.company.geo_zones
      @locations = current_user.company.locations.display
    end

    @events  = Event.all

    ### Se debe Definir si los dueños de las cargas (owners table) seran por compañia o genericos
    @owners = Owner.all
    @locations = Location.all
    @couples_types = CouplesType.all
    @travel_sheets = TravelSheet.all

    @device_positions = Hash[
      (current_user.global_admin? ? LastPositionFrame.all : current_user.company.last_position_frames).collect do |last_position_frame|
        [
          last_position_frame.imei,
          {
            imei: last_position_frame.imei,
            device_type: last_position_frame.device_type,
            coords: last_position_frame.geom.coordinates.reverse,
            velocity: last_position_frame.velocity,
            direction: last_position_frame.direction,
            altitude: last_position_frame.altitude,
            odometer: last_position_frame.odometer,
            date: last_position_frame.gps_date,
            gps_valid: last_position_frame.gps_valid,
            panic: last_position_frame.input_1,
            pointList: [{date: last_position_frame.gps_date, coords: last_position_frame.geom.coordinates.reverse}],
            door: last_position_frame.input_2,
            unhook: last_position_frame.input_3
          }
        ]
      end
    ]
    @unseen_alerts = (current_user.global_admin? ? Alert : current_user.company.alerts).unseen.order(inserted_at: :asc).all.map do |alert|
      {
        id: alert.id,
        device_id: alert.device_id,
        event_id: alert.event_id,
        coords: alert.geom.coordinates.reverse,
        seen: alert.seen,
        date: alert.gps_date,
        description: alert.description
      }
    end


    @geo_zones_histories_without_exit = (current_user.global_admin? ? GeoZoneHistory : current_user.company.geo_zones_histories).ordered.all.map do |geo_zone_history|
      {
          id: geo_zone_history.id,
          geo_zone_id: geo_zone_history.geo_zone_id,
          enter_time: geo_zone_history.enter_time,
          exit_time: geo_zone_history.exit_time
      }
    end

    @command_requests = CommandRequest.ordered.all.map do |current_request|
      {
          id: current_request.id,
          user_id: current_request.user_id,
          time_request: current_request.request_time,
          command_text: current_request.command_text,
          status: current_request.status,
          result_time: current_request.result_time,
          device_id: current_request.device_id
      }
    end
=begin
    @geo_zones = (current_user.global_admin? ? GeoZone : current_user.company.geo_zones).all.map do |geo_zone|
      geoJson = RGeo::GeoJSON.encode(geo_zone.geom)
      geoJson["properties"] ||= {}
      geoJson["properties"]["id"] = geo_zone.id
      geoJson["properties"]["enter_alert"] = geo_zone.enter_alert
      geoJson["properties"]["exit_alert"] = geo_zone.exit_alert
      geoJson["properties"]["name"] = geo_zone.name
      geoJson["properties"]["color"] = '#0000ff'
      geoJson["properties"]["radius"] = geo_zone.radius
      geoJson
    end
=end
  end
end
