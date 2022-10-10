Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users, only: %i[create show update destroy] do
    post '/login', to: 'users#login', as: :user_login, on: :collection
    post '/delete_account', to: 'users#delete_account', as: :user_delete_account, on: :collection
  end
  resources :events, only: %i[index create show update destroy]
end
