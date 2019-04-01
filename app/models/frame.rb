class Frame < ApplicationRecord
  scope :from_imei, -> (imei) { where(imei: imei) }
  scope :gps_date_gt, -> (gps_date) { where("gps_date > ?", gps_date) }
  scope :gps_date_lt, -> (gps_date) { where("gps_date < ?", gps_date) }
  scope :between_dates, -> (start, finish) { where(gps_date: start..finish) }
  scope :velocity_gt, -> (velocity_limit) { where("velocity > ?", velocity_limit) }
  scope :velocity_lte, -> (velocity_limit) { where("velocity <= ?", velocity_limit) }
  scope :ordered, -> { order(gps_date: :asc) }
  scope :valid, -> { where(gps_valid: true) }

  scope :position, -> { where("event_id = ? OR event_id = ?", 'tracker', '30') }
  scope :ignition_on, -> { where("event_id = ? OR event_id = ? ", 'acc on', '05') }
  scope :ignition_off, -> { where("event_id = ? OR event_id = ?", 'acc off', '06') }

  scope :stopped_with_ignition, -> { where("ignition = ? AND velocity <= ?",true, 5) }
  scope :stopped_without_ignition, -> { where("(ignition is NULL or ignition = ?) AND velocity <= ?",true, 5) }
  scope :driving, -> { where("velocity > ?",5) }

  belongs_to :device, foreign_key: 'imei', primary_key: 'imei'
  belongs_to :event, primary_key: 'syrus' 

  private
  def timestamp_attributes_for_create
    super << :inserted_at
  end
end
