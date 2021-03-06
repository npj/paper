class PostsController < ApplicationController
  
  before_filter :store_location, :only => :show
  before_filter :authenticate_user!, :except => [ :index, :show, :publish ]
  before_filter :find_posts, :only   => :index
  before_filter :find_post,  :except => [ :index, :new, :create ]
  before_filter :protect, :only => :show
  
  def index
    render(:locals => { :posts => @posts })
  end
  
  def new
    @post = Post.new
  end
  
  def create
    @post = Post.new((params[:post] || { }).merge(:user => current_user))
    if @post.save
      redirect_to(post_path(@post), :notice => t('posts.create.success'))
    else
      render(:action => :new, :notice => t('posts.create.failure'))
    end
  end
  
  def edit
    render(:new)
  end
  
  def update
    if @post.update_attributes(params[:post])
      redirect_to(post_path(@post), :notice => t('posts.update.success'))
    else
      render(:action => :new, :alert => t('posts.update.failure'))
    end
  end
  
  def destroy
    if @post.owned_by?(current_user)
      @post.destroy
      flash[:notice] = t('posts.delete.success')
    end
    redirect_to(root_path)
  end
  
  def publish
    if @post.owned_by?(current_user)
      @post.publish!
      flash[:notice] = t('posts.publish.success')
    end
    redirect_to(post_path(@post))
  end
  
  protected
    
    def find_posts
      @posts = Post.for_user(current_user).order_by([ :published_at, :desc ])
    end
  
    def find_post
      unless @post = Post.find_by_unique_id(params[:id].split(/\-/).first)
        render(:status => :not_found, :notice => t('posts.not_found'))
      end
    end
    
    # before_filter :only => :show
    # redirect user back to index if doesn't have
    # the approriate permissions
    def protect
      return true if @post.visible_to?(current_user)
      flash[:alert] = t("login_required")
      redirect_to(login_path)
    end
end
