Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  get "/api/v1/items", to: "api/v1/items#index"
  get "/api/v1/merchants", to: "api/v1/merchants#index"
  get "/api/v1/items/:id", to: "api/v1/items#show"
  get "/api/v1/merchants/:id", to: "api/v1/merchants#show"
  post "/api/v1/items", to: "api/v1/items#create"
  post "/api/v1/merchants", to: "api/v1/merchants#create"
  put "/api/v1/items/:id", to: "api/v1/items#update"
  patch "/api/v1/merchants/:id", to: "api/v1/merchants#update"
  delete "/api/v1/items/:id", to: "api/v1/items#destroy"
  delete "/api/v1/merchants/:id", to: "api/v1/merchants#destroy"

  # New route for merchant customers endpoint
  get "/api/v1/merchants/:merchant_id/customers", to: "api/v1/merchants/customers#index"
  #get is the HTTP verb
  #/api/v1/ is the namespace
  # :merchants_id is a dynamic segment. It will be replaced with the actual id of the merchant
  # a dynamic segment is a placeholder for a value that will be provided at runtime
  # customers is the controller
  # index is the action, which is the method in the controller that will be called
end
