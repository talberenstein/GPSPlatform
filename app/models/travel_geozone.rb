class TravelGeozone < ApplicationRecord
		belongs_to :travel_sheet
		has_many :geo_zones
		accepts_nested_attributes_for :geo_zones, allow_destroy: false
end
