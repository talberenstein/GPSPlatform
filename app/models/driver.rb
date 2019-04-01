class Driver < ApplicationRecord
  belongs_to :company
  has_many :devices

  validates :name, presence: true
  validates :rut, uniqueness: true

  def to_s
    "#{self.name} - #{self.rut}"
  end

  private
  def timestamp_attributes_for_create
    super << :inserted_at
  end
end
