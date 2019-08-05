Rails.application.routes.draw do
  # resources :auctions, only: [:index]
  # get '/', to: 'auctions#index
  # get '/' => 'auctions#index'
  root 'auctions#index'

#  get '/:locale/:region/:realm', to: 'auctions#index'
end
