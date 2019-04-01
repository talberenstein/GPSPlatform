class GeoZoneHistory < ApplicationRecord
  self.table_name = "geo_zones_histories"

  belongs_to :device
  belongs_to :geo_zone
  belongs_to :company

  scope :ordered, -> { order(enter_time: :desc) }
  scope :from_imei, -> (imei) { joins(:device).where("devices.imei": imei) }
  scope :between_dates, -> (start, finish) { where(enter_time: start..finish) }

  private
  def timestamp_attributes_for_create
    super << :inserted_at
  end
end
