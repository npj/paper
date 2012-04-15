class UserMailer < ActionMailer::Base
  default :from => "#{Paper.config.name} <no-reply@#{Paper.config.host}>"
  
  def notify_new_user(user)
    @user = user
    mail({
      :to      => Paper.config.owner.email,
      :subject => "New User!"
    })
  end
  
  def notify_new_comment(comment)
    @comment = comment
    @subject = "#{@comment.user.name} just left a comment on your #{@comment.commentable_type.downcase}."
    mail({
      :to      => comment.commentable.user.email,
      :subject => @subject
    })
  end
end
