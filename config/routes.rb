Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "greenhouse_api", to: "greenhouse_api#show"
      resources :greenhouse_api, only: [:index, :show, :create]
      get "products", to: "products#index"
      resources :products, only: [:index, :show, :create]
      # root 'products#index'
    end
  end
end
