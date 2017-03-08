Rails.application.routes.draw do
  resources :order_items
  resources :orders do
    collection do
      get 'queued'
      get 'in_progress'
      get 'ready'
      get 'released'
    end
  end
  resources :products

  root to: 'orders#new'
end
