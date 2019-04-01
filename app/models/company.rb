class Company < ApplicationRecord
    has_many :drivers
    has_many :devices
    has_many :geo_zones
    has_many :users
    has_many :alerts
    has_many :frames
    has_many :last_position_frames
    has_many :device_events
    has_many :geo_zones_histories, class_name: "GeoZoneHistory"
    has_many :daily_activity_histories
    has_many :groups
    has_many :travel_sheets
    has_many :owners
    has_many :routes
    has_many :locations
    has_many :couples_types

  def to_s
    self.name
  end

  private
  def timestamp_attributes_for_create
    super << :inserted_at
  end  
end
