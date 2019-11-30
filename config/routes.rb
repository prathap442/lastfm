Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/users/signup',to: "users#signup"
  post '/users',to: "users#create",as: 'users'
  get '/users/signin',to: "users#signin"
  get '/users/signinform',to: "users#signinform"
  root "users#signup"
  post '/users/signout',to:"users#signout",as: 'users_signout'
  post '/users/signinpost',to: 'users#signinpost'
  get '/welcomes',to: 'welcomes#index'
  post '/users/user_search',to: 'users#user_search'
end
