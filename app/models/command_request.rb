class CommandRequest < ApplicationRecord
  belongs_to :user
  belongs_to :device
  before_create :set_default

  #enum status: {pending: 0, sending: 1, send: 2, failed: 3}

  validates_presence_of :user_id, :device_id, :command_text

  scope :ordered, -> { order(request_time: :desc) }

  def set_default
    self.request_time = DateTime.now
    self.status = 0
  end

end
