class DeviceEvent < ApplicationRecord
    belongs_to :device
    belongs_to :event

    validates_presence_of :event, :device

    private
    def timestamp_attributes_for_create
        super << :inserted_at
    end
end
