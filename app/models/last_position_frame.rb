class LastPositionFrame < ApplicationRecord
  belongs_to :device, foreign_key: :imei, primary_key: :imei

  scope :valid, -> { where(gps_valid: true) }

  def stopped_with_ignition?
    self.ignition.nil? ? self.velocity <= 5 : self.velocity <= 5 && self.ignition 
  end

  def stopped_without_ignition?
    self.ignition.nil? ? self.velocity <= 5 : self.velocity <= 5 && !self.ignition 
  end

  def driving?
    self.velocity > 5
  end

  private
  def timestamp_attributes_for_create
    super << :inserted_at
  end
end
