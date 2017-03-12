class Product < ApplicationRecord

  def self.cached_products
    Rails.cache.fetch('products', expires_in: 10.minutes) { Product.all }
  end
end
