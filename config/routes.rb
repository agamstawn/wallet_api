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
end
