class WebserviceController < ApplicationController
  def index
    data = webservice_params
    puts data.inspect
    imei = data[:device]
    @webservice_record = []


    @webservice = Device.where(imei: imei)

    @webservice.each do |ws|

      #DEVICE & DRIVER DETAILS
      driver_id = ws.driver_id
      puts driver_id

      device_name = ws.name
      company_id = ws.company_id
      company_name = Company.where(id: company_id)[0].name
      device_phone = ws.phone

      driver_name = Driver.where(id: driver_id)[0].name
      puts driver_name

      #LAST_POSITION_FRAME DETAILS

      @lpf = LastPositionFrame.where(imei: imei)

      puts @lpf.inspect

      @lpf.each do |lpf|
        d_type = lpf.device_type
        puts d_type
        event_id = lpf.event_id
        event_name = Event.where(syrus: event_id)[0].name
        actual_location = lpf.geom.coordinates[1].to_s + " , " + lpf.geom.coordinates[0].to_s
        puts actual_location
        address_actual_location = Geocoder.address(actual_location).to_s
        puts address_actual_location
        gps_date = lpf.gps_date.strftime("%d/%m/%Y %H:%M:%S")
        velocity = lpf.velocity
        altitude = lpf.altitude

        @webservice_record << {
            imei: imei,
            device_name: device_name,
            company_name: company_name,
            device_phone: device_phone,
            driver_name: driver_name,
            device_type: d_type,
            event_name: event_name,
            address_actual: address_actual_location,
            gps_date: gps_date,
            velocity: velocity,
            altitude: altitude,
        }

      end


    end

    render json: @webservice_record

  end

  def webservice_params
    params.permit(:device)
  end
end
