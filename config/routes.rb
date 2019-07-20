Rails.application.routes.draw do
  resources :auctions, only: [:index]
end
