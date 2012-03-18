class Admin::GalleriesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_admin_galleries_role
  before_filter :require_reindex_galleries_role, :only => :reindex
  before_filter :require_delete_galleries_role, :only => :destroy
  before_filter :find_gallery, :only => [ :reindex, :destroy ]
  
  def index
    @galleries = Gallery.order_by([ :created_at, :desc ]).paginate(:page => params[:page], :per_page => 50)
  end
  
  def reindex
    @gallery.reindex
    flash[:notice] = t('admin.galleries.reindex.success', :name => @gallery.name)
    redirect_to(admin_galleries_path)
  end
  
  def destroy
    @gallery.destroy
    flash[:notice] = t('admin.galleries.delete_success', :name => @gallery.name)
    redirect_to(admin_galleries_path)
  end
  
  protected
  
    def require_admin_galleries_role
      unless current_user.has_role?(:admin_galleries)
        redirect_to(root_path)
      end
    end
    
    def require_reindex_galleries_role
      unless current_user.has_role?(:reindex_galleries)
        redirect_to(root_path)
      end
    end
    
    def require_delete_galleries_role
      unless current_user.has_role?(:delete_galleries)
        redirect_to(root_path)
      end
    end
    
    def find_gallery
      @gallery = Gallery.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      redirect_to(root_path)
    end
end
