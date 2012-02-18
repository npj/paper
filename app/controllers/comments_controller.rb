class CommentsController < ApplicationController
  
  before_filter :authenticate_user!
  
  def create
    @comment = Comment.new((params[:comment] || { }).merge(:user => current_user))
    if @comment.save
      redirect_to(post_path(@comment.post))
    else
      Rails.logger.info("@comment.errors: #{@comment.errors.full_messages.inspect}")
    end
  end
end
