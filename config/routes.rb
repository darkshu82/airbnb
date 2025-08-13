Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  namespace :api do
    resources :wishlists, only: [ :index, :create, :destroy ]

    # 세션 기반 로그인/로그아웃 엔드포인트
    post "login", to: "sessions#create"      # 또는 sessions
    delete "logout", to: "sessions#destroy"   # 또는 sessions

    # 기존 설정도 유지 (둘 다 사용 가능)
    devise_scope :user do
      post "sessions", to: "sessions#create"
      delete "sessions", to: "sessions#destroy"
    end
  end
end
