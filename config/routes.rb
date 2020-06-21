Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  root "works#root"
  # Omniauth Github Login Route
  get "/auth/github", as: "github_login"
  # Omniauth Github callback route
  get "/auth/:provider/callback", to: "users#create", as: "omniauth_callback"
  
  post "/logout", to: "users#logout", as: "logout"
  resources :users, only: [:index, :show]

  post "/works/:id/upvote", to: "works#upvote", as: "upvote"
  resources :works

end
