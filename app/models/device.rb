class Device < ApplicationRecord
    has_one :last_position_frame, foreign_key: :imei, primary_key: :imei
    has_many :device_events, dependent: :destroy
    has_many :couples_type
    has_many :alerts, dependent: :destroy
    has_many :events, through: :device_events
    belongs_to :company
    belongs_to :driver
    belongs_to :group

    has_many :couples_type

    validates :imei, presence: true
    validates :imei, uniqueness: true

    has_many :frames, foreign_key: 'imei', primary_key: 'imei'

    private
    def timestamp_attributes_for_create
        super << :inserted_at
    end
end
