class Location < ApplicationRecord
		belongs_to :travel_location
    scope :display, -> { where(is_display: true) }

    def location_render
      "#{location_name} (#{location_address})"
    end
end
