class Trip < ApplicationRecord
  belongs_to :route
  has_many :delivery_events, dependent: :destroy
  enum status: { pending: 0, in_progress: 1, completed: 2 }
end
