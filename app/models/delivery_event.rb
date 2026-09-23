class DeliveryEvent < ApplicationRecord
  belongs_to :trip
  enum :event_type, { delivery: 0, pickup: 1 }
  enum :status, { pending: 0, completed: 1, failed: 2 }
  validates :recipient_name, :address, presence: true
end
