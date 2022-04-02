Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :login, controller: 'sessions', only: :index do
    get :callback, on: :collection
  end

  resource :search, only: [:show]
end
