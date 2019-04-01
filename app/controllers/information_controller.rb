class InformationController < ApplicationController


		before_filter :set_dates, except: [:info, :speeds_graph, :stops_graph]

		def report_speeds_NO_USE_TAL
			velocity_limit = params[:velocity_limit].to_f
			imeis = params[:imeis]
			@geozona_record = []
			contador = params[:limit].to_f

			puts "Entre al REPORT"
			puts imeis

			imeis.each do |imei|


				device_id = Device.where(imei: imei)[0].id
				device_name = Device.where(imei: imei)[0].name
				th = tm = ts = ''

				@speed = Frame.where(imei: imei).between_dates(@from, @to).velocity_gt(velocity_limit).order('velocity ASC').limit contador
				puts @speed.inspect

				@speed.each do |t|

					date_from = t.gps_date.strftime("%d/%m/%Y %H:%M:%S")
					date_to = t.gps_date.strftime("%d/%m/%Y %H:%M:%S")
					duration_in_time = TimeDifference.between(t.gps_date, start_of_exceed.gps_date).in_general
					device_name = Device.where(imei: imei)[0].name
					@speed_record << {
							device_name: device_name,
							driver_name: driver_name,
							date_from: date_from,
							date_to: date_to,
							duration_in_km: duration_in_km,
							place_from: place_from,
							place_to: place_to,
							duration_in_time: duration_in_time,
							max_speed: max_speed,
							start_of_exceed: start_of_exceed,
							end_of_exceed: end_of_exceed,
							to_graph: '-',
							array_1: frame_between
					}
				end

			end


			render json: @geozona_record
		end

		def report_playback
				puts '-----'
				imei = params[:imei]
				puts imei
				puts '-----'
				frames = (current_user.global_admin? ? Frame : Frame).valid.position.between_dates(@from, @to).ordered.from_imei(imei)
				puts frames.inspect
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
				render json: @points
		end

		def report_alerts
				imeis = params[:imeis]
				@alert_record = []

				puts "Entre al REPORT"
				puts imeis

				imeis.each do |imei|


						device_id = Device.where(imei: imei)[0].id
						device_name = Device.where(imei: imei)[0].name

						puts device_id, device_name

						@alert = Alert.where(device_id: device_id).between_dates(@from, @to)
						puts @alert.inspect

						@alert.each do |t|
								date_from = t.gps_date.strftime("%d/%m/%Y %H:%M:%S")
								puts date_from

								event_name = Event.where(id: t.event_id)[0].name
								puts event_name

								location_coord = t.geom.coordinates[1].to_s + " , " + t.geom.coordinates[0].to_s
								puts location_coord
								location = Geocoder.address(location_coord).to_s
								puts location

								frame_between = Frame.select("geom, velocity").where(imei: imei, gps_date: t.gps_date)

								@alert_record << {
										date_from: date_from,
										device_name: device_name,
										event_name: event_name,
										location: location,
										details: '-',
										to_graph: '-',
										array_1: frame_between

								}

						end
				end

				render json: @alert_record

		end

		def report_speeds
				@velocity_limit = params[:velocity_limit].to_f
				imeis = params[:imeis]
				puts imeis.inspect
        i=0
        puts i

				@excesses = {}
				@speed_record = []
				exceeded_frames = Frame
				puts @from.inspect
				puts @to.inspect
				exceeded_frames = (current_user.global_admin? ? Frame : Frame).valid.position.between_dates(@from, @to).from_imei(imeis).ordered.velocity_gt(@velocity_limit)
				imeis = exceeded_frames.map { |f| f.imei }.uniq
				all_frames = (current_user.global_admin? ? Frame : Frame).valid.position.between_dates(@from, @to).ordered.from_imei(imeis)

				imeis.each do |imei|
						starting_time = @from.beginning_of_day
						@excesses[imei] = {excesses: []}

            while i < 1000
              i=i+1
								start_of_exceed = exceeded_frames.from_imei(imei).gps_date_gt(starting_time).first
								break unless start_of_exceed
								end_of_exceed = all_frames.from_imei(imei).gps_date_gt(start_of_exceed.gps_date).velocity_lte(@velocity_limit).first
								break unless end_of_exceed

								frames = exceeded_frames.from_imei(imei).between_dates(start_of_exceed.gps_date, end_of_exceed.gps_date)
								starting_time = end_of_exceed.gps_date
								@excesses[imei][:excesses] << {start_of_exceed: start_of_exceed, end_of_exceed: end_of_exceed, max_velocity: frames.maximum(:velocity)}
								##address = Geocoder.address("-33.41722168973038 , -70.61331510543823")


								date_from = start_of_exceed.gps_date.strftime("%d/%m/%Y %H:%M:%S")
								date_to = end_of_exceed.gps_date.strftime("%d/%m/%Y %H:%M:%S")


								place_from = start_of_exceed.geom.coordinates[1].to_s + " , " + start_of_exceed.geom.coordinates[0].to_s
								place_to = end_of_exceed.geom.coordinates[1].to_s + " , " + end_of_exceed.geom.coordinates[0].to_s

								puts place_from
								puts place_to

								place_from_geo = Geocoder.address(place_from)
								place_to_geo = Geocoder.address(place_to)
								th = tm = ts = ''
								duration_in_time = TimeDifference.between(end_of_exceed.gps_date, start_of_exceed.gps_date).in_general
								if duration_in_time[:hours] > 0
										th = "#{duration_in_time[:hours]} horas, "
								end

								if duration_in_time[:minutes] > 0
										tm = "#{duration_in_time[:minutes]} minutos, "
								end

								if duration_in_time[:seconds] > 0
										ts = "#{duration_in_time[:seconds]} segundos"
								end

								device_name = Device.where(imei: imei)[0].name
								driver_id = Device.where(imei: imei)[0].driver_id
								puts device_name
								driver_name = Driver.where(id: driver_id)[0].name

								duration_in_time = th+tm+ts
								#device_name = imei
								max_speed = frames.maximum(:velocity).to_s + ' Km/h'
								duration_in_km = (
								distance_gps([start_of_exceed.geom.coordinates[1],
								              start_of_exceed.geom.coordinates[0]],
								             [end_of_exceed.geom.coordinates[1],
                              end_of_exceed.geom.coordinates[0]]) / 1000).round(1).to_s + ' Km'

              frame_between = Frame.select("geom, velocity").where(imei: imei).between_dates(start_of_exceed.gps_date, end_of_exceed.gps_date)
							puts '+++++++++++++++++++'
							puts frame_between.inspect
							puts '+++++++++++++++++++'





              @speed_record << {
										device_name: device_name,
										driver_name: driver_name,
										date_from: date_from,
										date_to: date_to,
										duration_in_km: duration_in_km,
										place_from: place_from_geo,
										place_to: place_to_geo,
										duration_in_time: duration_in_time,
										max_speed: max_speed,
										start_of_exceed: start_of_exceed,
										end_of_exceed: end_of_exceed,
										to_graph: '-',
                    array_1: frame_between
								}

						end
				end
				render json: @speed_record

		end

		def report_activities
				imeis = params[:imeis]
				frames = (current_user.global_admin? ? Frame : Frame).valid.between_dates(@from, @to).ordered.from_imei(imeis)

				@activities_record = []

				puts "Entre al REPORT"
				puts imeis

				#hours = (@from_time - @to_time)/-3600
				#puts hours

				imeis.each do |imeis|


						device_name = Device.where(imei: imeis)[0].name

						@activities = Frame.where(imei: imeis).between_dates(@from, @to)

						puts @activities.inspect

						(@from.to_date..@to.to_date).each do |day|
								day_frames = frames.between_dates(day.beginning_of_day, day.end_of_day).from_imei(imeis)
								next unless day_frames.any?
								distance = 0
								drive_hours = 0
								stopoff_hours = 0
								stopon_hours = 0
								day_frames.each do |df|
										prev_frame = day_frames.gps_date_lt(df.gps_date).last
										next unless prev_frame
										distance += distance_gps(prev_frame.geom.coordinates.reverse, df.geom.coordinates.reverse)
										drive_hours += TimeDifference.between(df.gps_date, prev_frame.gps_date).in_hours if df.ignition
										puts "empieza stopoff"
										stopoff_hours += TimeDifference.between(df.gps_date, prev_frame.gps_date).in_hours if df.velocity <= 5 and !df.ignition
										puts "empieza stopon"
										stopon_hours += TimeDifference.between(df.gps_date, prev_frame.gps_date).in_hours if df.velocity <= 5 and df.ignition
										puts distance
										puts drive_hours
										puts stopoff_hours
										puts stopon_hours
										puts df.ignition
								end

								@activities_record << {
										device_name: device_name,
										date_from: day,
										distance: (distance / 1000).round(1),
										trips: day_frames.ignition_on.count,
										drive_hours: drive_hours.round(),
										stopoff_hours: (24 - drive_hours).round(),
										stopon_hours: stopon_hours.round
								}
						end
				end

				render json: @activities_record

		end


		def report_geozones

				imeis = params[:imeis]
				@geozona_record = []

				puts "Entre al REPORT"
				puts imeis

				imeis.each do |imei|


						device_id = Device.where(imei: imei)[0].id
						device_name = Device.where(imei: imei)[0].name
						puts device_id.inspect
						th = tm = ts = ''

						@geozona =GeoZoneHistory.where(device_id: device_id).between_dates(@from, @to)

						puts @geozona.inspect

						@geozona.each do |t|

								puts '-------'
								puts t.geo_zone_id


								geo_zone_name = GeoZone.where(id: t.geo_zone_id)[0].name
								puts geo_zone_name
								puts '-------'
								date_from = t.enter_time.strftime("%d/%m/%Y")
								puts date_from

								place_from = t.enter_location.coordinates[1].to_s + " , " + t.enter_location.coordinates[0].to_s
								puts place_from
								enter_address = Geocoder.address(place_from).to_s
								puts enter_address

								place_to = t.exit_location.coordinates[1].to_s + " , " + t.exit_location.coordinates[0].to_s
								puts place_to
								exit_address = Geocoder.address(place_to).to_s
								puts exit_address

								enter_odometer = t.enter_odometer
								puts enter_odometer

								enter_time = t.enter_time.strftime("%H:%M:%S")
								puts enter_time

								exit_odometer = t.exit_odometer
								exit_time = t.exit_time.strftime("%H:%M:%S")

								company_name = Company.where(id: t.company_id)[0].name
								puts company_name

								difference_time = TimeDifference.between(exit_time, enter_time).in_general
								puts difference_time

								if difference_time[:hours] > 0
										th = "#{difference_time[:hours]} horas, "
										puts th
								end

								if difference_time[:minutes] > 0
										tm = "#{difference_time[:minutes]} minutos, "
										puts tm
								end

								if difference_time[:seconds] > 0
										ts = "#{difference_time[:seconds]} segundos"
										puts ts
								end

								difference_time = th + tm + ts
								puts difference_time

								difference_odometer = exit_odometer - enter_odometer

								frame_between = Frame.select("geom, velocity").where(imei: imei).between_dates(t.enter_time, t.exit_time)
								puts '+++++++++++++++++++'
								puts frame_between.inspect
								puts '+++++++++++++++++++'

								@geozona_record << {
										date_from: date_from,
										geo_zone_name: geo_zone_name,
										device_name: device_name,
										enter_time: enter_time,
										enter_adress: enter_address,
										enter_odometer: (enter_odometer/1000).round(4),
										exit_time: exit_time,
										exit_address: exit_address,
										exit_odometer: (exit_odometer/1000).round(4),
										difference_time: difference_time,
										difference_odometer: (difference_odometer/1000).round(4),
										to_graph: '-',
										array_1: frame_between
								}


						end
				end


				render json: @geozona_record

		end


		def report_stops
				@velocity_limit = 5
				imeis = params[:imeis]
				min_stop = params[:stop_limit]

				puts min_stop

				@excesses = {}
				@speed_record = []
        i=0

        puts i
				exceeded_frames = (current_user.global_admin? ? Frame : Frame).valid.position.between_dates(@from, @to).from_imei(imeis).ordered.velocity_lte(5)
				imeis = exceeded_frames.map { |f| f.imei }.uniq
				all_frames = (current_user.global_admin? ? Frame : Frame).valid.position.between_dates(@from, @to).ordered.from_imei(imeis)

				imeis.each do |imei|
						starting_time = @from.beginning_of_day
						@excesses[imei] = {excesses: []}

						while i < 1000
                i=i+1
								start_of_exceed = exceeded_frames.from_imei(imei).gps_date_gt(starting_time).first
								break unless start_of_exceed
								end_of_exceed = all_frames.from_imei(imei).gps_date_gt(start_of_exceed.gps_date).velocity_gt(5).first
								break unless end_of_exceed

								frames = exceeded_frames.from_imei(imei).between_dates(start_of_exceed.gps_date, end_of_exceed.gps_date)
								starting_time = end_of_exceed.gps_date
                puts 'de nuevo :S'
								@excesses[imei][:excesses] << {start_of_exceed: start_of_exceed, end_of_exceed: end_of_exceed, max_velocity: frames.maximum(:velocity)}
								##address = Geocoder.address("-33.41722168973038 , -70.61331510543823")


								date_from = start_of_exceed.gps_date.strftime("%d/%m/%Y %H:%M:%S")
								date_to = end_of_exceed.gps_date.strftime("%d/%m/%Y %H:%M:%S")


								place_from = start_of_exceed.geom.coordinates[1].to_s + " , " + start_of_exceed.geom.coordinates[0].to_s
								place_to = start_of_exceed.geom.coordinates[1].to_s + " , " + start_of_exceed.geom.coordinates[0].to_s

								place_from = Geocoder.address(place_from)
								#place_to = Geocoder.address(place_to)
								th = tm = ts = ''
								duration_in_time = TimeDifference.between(end_of_exceed.gps_date, start_of_exceed.gps_date).in_general

								aux = false
								if duration_in_time[:hours] > 0
										th = "#{duration_in_time[:hours]} horas, "
								end

								if duration_in_time[:minutes] > 0
										tm = "#{duration_in_time[:minutes]} minutos, "
										if (duration_in_time[:minutes] >= min_stop.to_i &&  duration_in_time[:hours]<1) || duration_in_time[:hours]>=1
											aux = true
										end
								end

								if duration_in_time[:seconds] > 0
										ts = "#{duration_in_time[:seconds]} segundos"
								end

								duration_in_time = th+tm+ts
								#Device.select("name").where(imei = '868683028151573')
								#device_name = Device.select("name").where(imei: '868683028151573').to_s
								#device_name_2 = imei
								device_name = Device.where(imei: imei)[0].name
								driver_id = Device.where(imei: imei)[0].driver_id
								puts device_name
								driver_name = Driver.where(id: driver_id)[0].name
								max_speed = frames.maximum(:velocity).to_s + ' Km/h'
								duration_in_km = (
								distance_gps([start_of_exceed.geom.coordinates[1],
								              start_of_exceed.geom.coordinates[0]],
								             [end_of_exceed.geom.coordinates[1],
								              end_of_exceed.geom.coordinates[0]]) / 1000).round(1).to_s + ' Km'

								puts duration_in_km

								puts duration_in_time
								puts min_stop

								frame_between = Frame.select("geom, velocity").where(imei: imei).between_dates(start_of_exceed.gps_date, end_of_exceed.gps_date)
								puts '+++++++++++++++++++'
								puts frame_between.inspect
								puts '+++++++++++++++++++'

								if aux
									@speed_record << {
											device_name: device_name,
											driver_name: driver_name,
											date_from: date_from,
											date_to: date_to,
											place_from: place_from,
											duration_in_time: duration_in_time,
											start_of_exceed: start_of_exceed,
											end_of_exceed: end_of_exceed,
											to_graph: '-',
											array_1: frame_between
									}
								end


						end
				end
				render json: @speed_record
		end

		def report_dialyActivities

				imeis = params[:imeis]
        @frames = Frame.includes(:device, :event).where(imei: imeis).between_dates(@from, @to)
        @parsed_frames = @frames.map{|f| {
          device_name: f.device.name,
          event_id: f.event.name,
          gps_date: f.gps_date.strftime("%d/%m/%Y %H:%M:%S"),
          imei: f.imei,
          velocity: f.velocity.round,
          address: Geocoder.address("#{f.geom.coordinates[1]}, #{f.geom.coordinates[0]}").to_s,
					battery_voltage: f.battery_voltage.to_f,
					altitude: f.altitude,
					direction: f.direction,
					position_type: f.position_type,
					position_antiquity: f.position_antiquity,
					odometer: f.odometer,
					seen_satellites: f.seen_satellites,
					gps_valid: f.gps_valid,
					to_graph: '-',
					array_1: []
          }
        }
        render json: @parsed_frames
=begin
				@trama_record = []

				puts imeis

				imeis.each do |imei|


						@tramas = Frame.where(imei: imei).between_dates(@from, @to)
						device_name = Device.where(imei: imei)[0].name
						puts device_name
						@tramas.each do |t|
								place_from = t.geom.coordinates[1].to_s + " , " + t.geom.coordinates[0].to_s
								puts place_from
								address = Geocoder.address(place_from).to_s
								puts address
								event_id = t.event_id
								event_name = Event.where(syrus: event_id)[0].name
								puts event_name.inspect
								gps_date = t.gps_date.strftime("%d/%m/%Y %H:%M:%S")
								imei = t.imei
								velocity = t.velocity
								battery_voltage = t.battery_voltage.to_f
								puts event_id
								altitude = t.altitude
								direction = t.direction
								position_type = t.position_type
								position_antiquity = t.position_antiquity
								odometer = t.odometer
								seen_satellites = t.seen_satellites
								gps_valid = t.gps_valid

								frame_between = Frame.select("geom, velocity").where(imei: imei, gps_date: t.gps_date)
								@trama_record << {
										device_name: device_name,
										event_id: event_name,
										gps_date: gps_date,
										imei: imei,
										velocity: velocity.round,
										address: address,
										battery_voltage: battery_voltage,
										altitude: altitude,
										direction: direction,
										position_type: position_type,
										position_antiquity: position_antiquity,
										odometer: odometer,
										seen_satellites: seen_satellites,
										gps_valid: gps_valid,
										to_graph: '-',
										array_1: frame_between

								}


						end
				end


				render json: @trama_record
=end
		end


		def report_dialyActivities2_NOT_USE
				contador = params[:limit].to_f
				@velocity_limit = 0
				i=0
				imeis = params[:imeis]

				@excesses = {}
				@speed_record = []
				exceeded_frames = (current_user.global_admin? ? Frame : current_user.company.frames).valid.position.between_dates(@from, @to).from_imei(imeis).ordered.velocity_gt(@velocity_limit)
				imeis = exceeded_frames.map { |f| f.imei }.uniq
				all_frames = (current_user.global_admin? ? Frame : current_user.company.frames).valid.position.between_dates(@from, @to).ordered.from_imei(imeis)

				imeis.each do |imei|
						puts "Entre al each do"
						puts contador

						starting_time = @from.beginning_of_day
						@excesses[imei] = {excesses: []}

						while i < contador
								puts "Entre al while"
								puts i
								start_of_exceed = exceeded_frames.from_imei(imei).gps_date_gt(starting_time).first
								break unless start_of_exceed
								end_of_exceed = all_frames.from_imei(imei).gps_date_gt(start_of_exceed.gps_date).velocity_lte(@velocity_limit).first
								break unless end_of_exceed

								frames = exceeded_frames.from_imei(imei).between_dates(start_of_exceed.gps_date, end_of_exceed.gps_date)
								starting_time = end_of_exceed.gps_date
								@excesses[imei][:excesses] << {start_of_exceed: start_of_exceed, end_of_exceed: end_of_exceed, max_velocity: frames.maximum(:velocity)}
								##address = Geocoder.address("-33.41722168973038 , -70.61331510543823")


								date_from = start_of_exceed.gps_date.strftime("%d/%m/%Y %H:%M:%S")
								date_to = end_of_exceed.gps_date.strftime("%d/%m/%Y %H:%M:%S")


								place_from = start_of_exceed.geom.coordinates[1].to_s + " , " + start_of_exceed.geom.coordinates[0].to_s
								place_to = end_of_exceed.geom.coordinates[1].to_s + " , " + end_of_exceed.geom.coordinates[0].to_s

								place_from = Geocoder.address(place_from)
								place_to = Geocoder.address(place_to)
								th = tm = ts = ''
								duration_in_time = TimeDifference.between(end_of_exceed.gps_date, start_of_exceed.gps_date).in_general
								if duration_in_time[:hours] > 0
										th = "#{duration_in_time[:hours]} horas, "
								end

								if duration_in_time[:minutes] > 0
										tm = "#{duration_in_time[:minutes]} minutos, "
								end

								if duration_in_time[:seconds] > 0
										ts = "#{duration_in_time[:seconds]} segundos"
								end

								device_name = Device.where(imei: imei)[0].name
								driver_id = Device.where(imei: imei)[0].driver_id
								puts device_name
								driver_name = Driver.where(id: driver_id)[0].name


								duration_in_time = th+tm+ts
								#device_name = imei
								max_speed = frames.maximum(:velocity).to_s + ' Km/h'
								duration_in_km = (
								distance_gps([start_of_exceed.geom.coordinates[1],
								              start_of_exceed.geom.coordinates[0]],
								             [end_of_exceed.geom.coordinates[1],
								              end_of_exceed.geom.coordinates[0]]) / 1000).round(1).to_s + ' Km'


								puts duration_in_km
								i=i+1;
								@speed_record << {
										device_name: device_name,
										driver_name: driver_name,
										date_from: date_from,
										date_to: date_to,
										duration_in_km: duration_in_km,
										place_from: place_from,
										place_to: place_to,
										duration_in_time: duration_in_time,
										max_speed: max_speed,
										start_of_exceed: start_of_exceed,
										end_of_exceed: end_of_exceed,
										to_graph: '-'
								}

						end
				end
				render json: @speed_record

		end


		def report_speeds_no_USE
				data = (information_params)
				data.each do |key|
						return render json: {
								device_name: '-',
								icon: '-',
								imei: '-',
								name: '-',
								rut: '-',
								gps_date: '-',
								gps_date: '-',
								geom: '-',
								error: "Todos los campos son requeridos"
						} if data[key].blank?
				end
				return render json: {
						device_name: '-',
						icon: '-',
						imei: '-',
						name: '-',
						rut: '-',
						gps_date: '-',
						gps_date: '-',
						geom: '-',
						error: "Seleccione al menos un dispositivo "} if data[:device] == nil
				@frames = Frame.select('frames.imei,frames.gps_date,frames.geom,round( velocity, 1) as velocity, devices.*, devices.name as device_name, drivers.*')
						          .joins('left join devices on devices.imei = frames.imei')
						          .joins('left join drivers on drivers.id = devices.driver_id')
						          .where(
								          'frames.gps_date >= ? AND frames.gps_date <= ? AND frames.velocity >= ? AND frames.velocity <= ? AND frames.imei in (?)',
								          data[:i_date],
								          data[:f_date],
								          data[:i_speed],
								          data[:f_speed],
								          data[:device]
						          )
				render json: @frames

				before_filter :set_dates


				private
				def information_params
						params.require(:report_speeds).permit(:i_date, :f_date, :i_speed, :f_speed, :device => [])
				end


				def set_dates
						@from = Time.parse("#{params[:from_date]} #{params[:from_time]}")
						@to = Time.parse("#{params[:to_date]} #{params[:to_time]}")
				end

		end


		def information_stop_params
				params.permit(:i_date, :f_date, :device => [])
		end

		def information_travelplay_params
				params.permit(:i_date, :f_date, :device)
		end

		def information_diaryactivities_params
				params.permit(:device)
		end

		def set_dates
				@from = Time.parse("#{params[:from_date]} #{params[:from_time]}")
				@from = @from + 5*60*60
				puts @from.inspect
				@to = Time.parse("#{params[:to_date]} #{params[:to_time]}")
				@to = @to + 5*60*60
				puts @to.inspect

		end

end
