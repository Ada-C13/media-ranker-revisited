Rails.application.routes.draw do
  root "works#root"

  #Omniauth Login Route
  get "/auth/github", as: "github_login"
  delete "/logout", to: "users#destroy", as: "logout"


  #Omniauth Github callback route
  get "/auth/:provider/callback", to: "users#create", as: "omniauth_callback"

  resources :works
  post "/works/:id/upvote", to: "works#upvote", as: "upvote"

  resources :users, only: [:index, :show]
end
