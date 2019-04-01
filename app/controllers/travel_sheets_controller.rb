class TravelSheetsController < ApplicationController
		before_action :set_travelsheet, only: [:update, :destroy]
		#before_action :set_travel_location, only: [:destroy]

		# POST /travelsheets
		# POST /travelsheets.json

		def edit
				ts_id = travel_sheet_params_details

				@travel_sheet = TravelSheet.where(id: ts_id['ts'])

				render :json => @travel_sheet,
				       :include => {
						       :travel_locations => {:include => :locations},
						       :owner => {},
						       :driver => {},
						       :couples_type => {},
						       :device => {},
						       :travel_routes => {:include => :routes}
				       }
		end

		def get_state
				ts_id = travel_sheet_params_details
				@travel_sheet = TravelSheet.where(id: ts_id['ts'])
				render :json => @travel_sheet,
				       :include => {
						       :travel_locations => {:include => :locations},
				       }
		end

		def set_state
				@travel_sheet = TravelSheet.find(params[:id])
				@travel_sheet.state = params[:state]
				@travel_sheet.save
		end

		def search
				ts_dates = travel_sheet_params_search
				ts_dates['from_date'] = ts_dates['from_date'].to_s + ' 00:00:00'
				ts_dates['to_date'] = ts_dates['to_date'].to_s + ' 23:59:59'

				@travel_sheet = TravelSheet.where.not(state: 'deleted').where(:date_travel => ts_dates['from_date']..ts_dates['to_date'], company_id: current_user.company_id).order('id DESC')

				render :json => @travel_sheet,
				       :include => {
						       :travel_locations => {:include => :locations},
						       :owner => {},
						       :driver => {},
						       :couples_type => {},
						       :device => {},
						       :travel_routes => {:include => :routes}
				       }
		end

		def details
				ts_id = travel_sheet_params_details
				@ts_details = TravelSheet.where(id: ts_id['ts'])
				render :layout => "simple"
		end

		def create
				ts_params = travel_sheet_params
				if ts_params[:id]
						@travel_sheet = TravelSheet.find(ts_params[:id])
						@travel_sheet.state = 'deleted'
						@travel_sheet.save
				end
				puts travel_sheet_params.inspect

				ts_params[:id] = nil
				@travel_sheet = TravelSheet.new(ts_params)
				@travel_sheet.created_from = current_user.id
				@travel_sheet.company_id = current_user.company_id
				@travel_sheet.modified_from = current_user.id

				if @travel_sheet.save
						render json: {response: @travel_sheet}
				else
						render json: {response: @travel_sheet.errors.full_messages.map { |e| e+'<br>' }.join}
				end


		end

		# PATCH/PUT /couples_types/1
		# PATCH/PUT /couples_types/1.json
		def update
				respond_to do |format|
						@travel_sheet.modified_from = current_user.id
						if @travel_sheet.update(travel_sheet_params)
								format.js {}
						else
								format.js {}
						end
				end
		end

		def destroy
				@travel_sheet = TravelSheet.find(params[:id])
				@travel_sheet.state = 'deleted'
				@travel_sheet.save
				###@travel_sheet.destroy
				respond_to do |format|
						format.js {}
				end
		end

		private

		def set_travel_location
				@travel_location = TravelLocation.find(params[:travel_sheet_id])
		end

		def set_travelsheet
				@travel_sheet = TravelSheet.find(params[:id])
		end

		def location_params(x)
				x[:travel_sheet][:position_origin].permit(:location_name, :location_address, :coordinate, :company_id, :is_display)
		end

		def travel_sheet_params_details
				params.permit(:ts)
		end
		def travel_sheet_params_search
				params.permit(:from_date,:to_date)
		end

		def travel_sheet_params

				obj = params

				obj["travel_locations_attributes"].each do |i, tla|
						tla["locations_attributes"].each do |j, la|
								la["coordinate"] = "POINT(#{la['coordinate']})"
								la["company_id"] = current_user.company_id
						end
				end if obj["travel_locations_attributes"] != nil
				##travel_location
				obj["travel_routes_attributes"].each do |i, tla|
						tla["routes_attributes"].each do |j, la|
								la["route_geo"] = "LINESTRING(#{la['route_geo']})"
						end
				end if obj["travel_routes_attributes"] != nil
				##travel_route
=begin
				obj["travel_alloweds_attributes"].each do |i, tla|
						tla["allowed_zones_attributes"].each do |j, la|
								la["allowed_geo"] = "LINESTRING(#{la['allowed_geo']})"
						end
				end if obj["travel_allowed_attributes"] != nil
=end
				##travel_zone
				obj.permit(
						:id,
						:prev_id,
						:travel_name,
						:date_travel,
						:company_id,
						:state,
						:is_template,
						:device_id,
						:couples_type_id,
						:driver_id,
						:owner_id,
						travel_locations_attributes: [
								:travel_sheet_id,
								:end_time,
								:start_time,
								:state,
								:step,
								locations_attributes: [
										:location_name,
										:location_address,
										:travel_location_id,
										:company_id,
										:is_display,
										:coordinate
								]
						],
						travel_routes_attributes: [
								:travel_sheet_id,
								routes_attributes: [
										:travel_route_id,
										:company_id,
										:route_name,
										:route_geo,
										:route_duration,
										:route_toll,
										:route_distance,
										:from,
										:to,
								    :maneuver
								]


						],
						travel_geozone_attributes: [
								:travel_sheet_id,
								geo_zones_attributes: [
										:name,
										:travel_geozone_id,
										:enter_alert,
										:exit_alert,
										:geom,
										:company_id,
										:radius

								]
						]
				)
				##params.permit!
		end


end





