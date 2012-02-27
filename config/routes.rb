Paper::Application.routes.draw do
  resources :posts do
    member { post :publish }
  end
  resources :comments

  devise_for :users
  
  devise_scope :user do
    get    "/signup" => "devise/registrations#new", :as => :signup
    get    "/login"  => "devise/sessions#new",      :as => :login
    delete "/logout" => "devise/sessions#destroy",  :as => :logout
  end
  
  root :to => "posts#index"
end
