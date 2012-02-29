class PostsController < ApplicationController
  
  before_filter :authenticate_user!, :except => [ :index, :show, :publish ]
  
  before_filter :find_posts, :only   => :index
  before_filter :find_post,  :except => [ :index, :new, :create ]
  
  def index
    render(:locals => { :posts => @posts, :post => @posts.shift })
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
      render(:action => :new, :notice => t('posts.update.failure'))
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
      @post = Post.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      render(:status => :not_found, :notice => t('posts.not_found'))
    end
end
