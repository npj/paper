class Admin::UsersController < ApplicationController
  
  before_filter :authenticate_user!
  before_filter :require_admin_users_role
  before_filter :require_delete_users_role, :only => :destroy
  before_filter :find_user, :only => :destroy
  
  def index
    @users = User.order_by([ :created_at, :desc ]).paginate(:page => params[:page], :per_page => 50)
  end
  
  def destroy
    unless @user.is_owner?
      @user.destroy
      flash[:notice] = t('admin.users.delete_success', :name => @user.name)
    end
    redirect_to(admin_users_path)
  end
  
  protected
    
    def require_admin_users_role
      unless current_user.has_role?(:admin_users)
        redirect_to(root_path)
      end
    end
    
    def require_delete_users_role
      unless current_user.has_role?(:delete_users)
        redirect_to(root_path)
      end
    end
    
    def find_user
      @user = User.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      redirect_to(root_path)
    end
end
