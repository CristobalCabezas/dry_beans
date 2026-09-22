class Route < ApplicationRecord
  has_many :trips, dependent: :destroy
  enum status: { planned: 0, in_progress: 1, completed: 2 }
end
