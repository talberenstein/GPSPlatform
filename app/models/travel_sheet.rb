class TravelSheet < ApplicationRecord
		validates :travel_name, presence: true
		validates :device_id, presence: true
		validates :driver_id, presence: true
		validates :owner_id, presence: true

		belongs_to :company
		belongs_to :couples_type
		belongs_to :driver
		belongs_to :owner
		belongs_to :device

		has_many :travel_locations
		has_many :travel_routes
		has_many :travel_geozones

		has_many :locations, through: :travel_locations
		has_many :routes, through: :travel_routes
		has_many :geo_zones, through: :travel_geozones

		accepts_nested_attributes_for :travel_locations , allow_destroy: true
		accepts_nested_attributes_for :travel_routes , allow_destroy: true
		accepts_nested_attributes_for :travel_geozones , allow_destroy: true


end