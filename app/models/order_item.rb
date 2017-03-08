class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  STEPS = %w(new queued in_progress ready released)
end
