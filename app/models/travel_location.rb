class TravelLocation < ApplicationRecord
		belongs_to :travel_sheet
		has_many :locations
		accepts_nested_attributes_for :locations, allow_destroy: true
end
