class Order < ApplicationRecord
  has_many :order_items, inverse_of: :order
  accepts_nested_attributes_for :order_items, reject_if: lambda{ |attributes| attributes['product_id'].blank? }

  STEPS = %w(new queued in_progress ready released)
end
