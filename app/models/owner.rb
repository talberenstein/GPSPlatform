class Owner < ApplicationRecord
  belongs_to :location
  belongs_to :company

  validates :owner_name, presence: true


end
