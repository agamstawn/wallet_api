Rails.application.routes.draw do
  resource :session, only: %i[create destroy]

  resources :wallets, only: :show do
    member do
      get  :balance
      post :deposit
      post :withdraw
      post :transfer
    end
  end

  get "stock_prices/price",     to: "stock_prices#price"
  get "stock_prices/prices",    to: "stock_prices#prices"
  get "stock_prices/price_all", to: "stock_prices#price_all"
end
