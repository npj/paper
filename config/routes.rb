Paper::Application.routes.draw do
  
  resources :posts do
    member { post :publish }
  end
  
  resources :images
  resources :comments

  devise_for :users, :controllers => { :registrations => "accounts" }
  
  devise_scope :user do
    get    "/signup" => "accounts#new",             :as => :signup
    get    "/login"  => "devise/sessions#new",      :as => :login
    delete "/logout" => "devise/sessions#destroy",  :as => :logout
  end
  
  root :to => "posts#index"
end
