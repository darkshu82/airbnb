Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  namespace :api do
    resources :wishlists, only: [ :index, :create, :destroy ]
    resources :wishlist_maps, only: [ :index ]
  end

  resources :properties, only: [ :show ]
end
