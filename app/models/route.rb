class Route < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :route_date, presence: true
  validates :status, presence: true
  has_many :trips, dependent: :destroy
  enum :status, { planned: 0, in_progress: 1, completed: 2 }
end
