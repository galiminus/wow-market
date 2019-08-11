Rails.application.routes.draw do
  # resources :auctions, only: [:index]
  # get '/', to: 'auctions#index
  # get '/' => 'auctions#index'
  root 'auctions#index'
  resources :auctions, only: [:index, :show]
  
#  get '/:locale/:region/:realm', to: 'auctions#index'
end
