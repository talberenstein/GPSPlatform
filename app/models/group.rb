class Group < ApplicationRecord
  belongs_to :company
  has_many :devices
  has_and_belongs_to_many :users, inverse_of: :groups

  validates :name, uniqueness: { scope: :company_id }
  validates :name, presence: true

  def to_s
    self.name
  end
end
