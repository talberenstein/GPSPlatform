class CouplesType < ApplicationRecord

  validates :couple_name, presence: true, uniqueness: true
  validates_numericality_of :high, greater_than: 0
  validates_numericality_of :width, greater_than: 0
  validates_numericality_of :long, greater_than: 0
  validates_numericality_of :weight, greater_than: 0

  alias_attribute :Tipo, :couple_name
  alias_attribute :Alto, :high


end
