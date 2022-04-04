require 'sidekiq/web' unless ENV['RAILS_ENV'] == 'production'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :login, controller: 'sessions', only: :index do
    get :callback, on: :collection
  end

  resource :search, only: [:show, :create]

  resources :rooms, only: %i[index create show]

  resources :queued_songs, only: :create

  mount Sidekiq::Web => "/sidekiq" unless ENV['RAILS_ENV'] == 'production'
end
