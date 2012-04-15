class CommentObserver < Mongoid::Observer
  def after_create(comment)
    unless comment.user == comment.commentable.user
      UserMailer.notify_new_comment(comment).deliver
    end
  end
end