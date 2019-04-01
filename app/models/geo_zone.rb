class GeoZone < ApplicationRecord
  belongs_to :company
  belongs_to :travel_geozone

  validates :name, presence: true

  private
  def timestamp_attributes_for_create
    super << :inserted_at
  end
end
