class LocationsController < ApplicationController
		before_action :set_location, only: [:update, :destroy]

=begin
		def index
				@locations = current_user.global_admin? ? Location.all : current_user.company.locations
		end
=end

		# POST /locations
		# POST /locations.json
		def create
				data = location_params
				data[:coordinate] = RGeo::Cartesian.factory(:srid => 4326).parse_wkt('POINT('+data[:coordinate]+')')
				data[:company_id] = current_user.company_id
				data[:is_display] = true
				@location = Location.new(data)
				respond_to do |format|
						if @location.save
								format.js {}
						else
								format.js {}
						end
				end
		end

		# PATCH/PUT /locations/1
		# PATCH/PUT /locations/1.json
		def update
				data = location_params
				data[:coordinate] = RGeo::Cartesian.factory(:srid => 4326).parse_wkt('POINT('+data[:coordinate]+')')

				respond_to do |format|
						if @location.update(data)
								format.js {}
						else
								format.js {}
						end
				end
		end

		# DELETE /locations/1
		# DELETE /locations/1.json
		def destroy
				@location.destroy
				respond_to do |format|
						format.js {}
				end
		end

		private
		# Use callbacks to share common setup or constraints between actions.
		def set_location
				@location = Location.find(params[:id])
		end

		# Never trust parameters from the scary internet, only allow the white list through.
		def location_params
				params.require(:location).permit(:location_name, :location_address, :coordinate,:company_id)
		end
end
