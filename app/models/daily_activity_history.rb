class DailyActivityHistory < ApplicationRecord
  belongs_to :device
  belongs_to :company

  scope :ordered, -> { order(day: :asc) }
  scope :from_imei, -> (imei) { joins(:device).where("devices.imei": imei) }
  scope :between_dates, -> (start, finish) { where(day: start..finish) }

  private
  def timestamp_attributes_for_create
    super << :inserted_at
  end
end
