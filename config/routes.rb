Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root "works#root"

  resources :works
  post "/works/:id/upvote", to: "works#upvote", as: "upvote"

  resources :users, only: [:index, :show]

  # Omniauth login route
  get "/auth/github", as: "github_login"

  # Omniauth Github callback 
  get "/auth/:provider/callback", to: "users#login", as: "login"

  delete "/logout", to: "users#logout", as: "logout"
end
