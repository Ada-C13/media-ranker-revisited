Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "works#root"
  
  resources :users, only: [:index, :show]
  resources :works
  post "/works/:id/upvote", to: "works#upvote", as: "upvote"


  # OmniAuth login
  get "/auth/github", as: "github_login"
  
  # OmniAuth callback
  get "/auth/:provider/callback", to: "users#create", as: "omniauth_callback"

  
  # post "/logout", to: "users#logout", as: "logout"
  delete "/logout", to: "users#destroy", as: "logout"
  
end
