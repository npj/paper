class PostsController < ApplicationController
  
  before_filter :authenticate_user!, :except => [ :index, :show ]
  
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
  
  def destroy 
    @post.destroy
    redirect_to(root_url)
  end
  
  protected
  
    def find_posts
      @posts = Post.for_user(current_user)
    end
  
    def find_post
      @post = Post.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      render(:status => :not_found, :notice => t('posts.not_found'))
    end
end
