class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable

  belongs_to :company
  has_many :location
  has_and_belongs_to_many :groups

  accepts_nested_attributes_for :groups, allow_destroy: true


  enum role: [:global_admin, :company_admin, :company_viewer]
  #enum send_command: {permit: TRUE, no_permit: FALSE}

  #alias_method :can_send_commands?, :send_command

  def send_command?
    self.send_command
  end

  private
  def timestamp_attributes_for_create
    super << :inserted_at
  end
end
