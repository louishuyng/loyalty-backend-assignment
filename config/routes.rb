Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  # TODO: only allow admin to access this page
  mount Sidekiq::Web => '/sidekiq'
end
