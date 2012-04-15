class ApplicationController < ActionController::Base
  protect_from_forgery
  
  protected
  
    def store_location
      session[:user_return_to] = request.path
    end
end
