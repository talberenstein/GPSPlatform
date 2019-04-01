class Event < ApplicationRecord
  has_many :device_events, dependent: :destroy
  has_many :alerts, dependent: :destroy
  has_many :devices, through: :device_events
  has_many :frames, primary_key: 'syrus'

  private
  def timestamp_attributes_for_create
    super << :inserted_at
  end
end
