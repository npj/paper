class UserMailer < ActionMailer::Base
  default :from => "#{Paper.config.name} <no-reply@#{Paper.config.host}>"
  
  def notify_new_user(user)
    @user = user
    mail({
      :to      => Paper.config.owner.email,
      :subject => "New User!"
    })
  end
end
