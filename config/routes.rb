Paper::Application.routes.draw do
  resources :posts
  resources :comments

  devise_for :users
  
  root :to => "posts#index"
end
