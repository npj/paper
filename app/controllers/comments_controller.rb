class CommentsController < ApplicationController
  
  before_filter :authenticate_user!
  before_filter :find_comment, :except => :create
  
  def create
    @comment = Comment.new((params[:comment] || { }).merge(:user => current_user))
    if @comment.save
      redirect_to(polymorphic_path(@comment.commentable, :anchor => @comment.id))
    else
      Rails.logger.info("@comment.errors: #{@comment.errors.full_messages.inspect}")
    end
  end
  
  def destroy
    @comment.delete!
    flash[:notice] = t("comments.deleted")
    redirect_to(polymorphic_path(@comment.commentable))
  end
  
  protected 
  
    def find_comment
      @comment = Comment.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      redirect_to(posts_path)
    end
end
