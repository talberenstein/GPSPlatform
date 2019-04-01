class TravelRoute < ApplicationRecord
		belongs_to :travel_sheet
		has_many :routes
		accepts_nested_attributes_for :routes, allow_destroy: true
end
