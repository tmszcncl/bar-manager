Rails.application.routes.draw do
  resources :order_items
  resources :orders
  resources :products

  root to: 'orders#new'
end
