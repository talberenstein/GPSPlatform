class Alert < ApplicationRecord
  belongs_to :event
  belongs_to :device

  scope :unseen, -> {where(seen: false)}
  scope :between_dates, -> (start, finish) { where(gps_date: start..finish) }


  private
  def timestamp_attributes_for_create
    super << :inserted_at
  end
end
