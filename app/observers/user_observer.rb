class UserObserver < Mongoid::Observer
  def before_create(user)
    user.add_role(:write_comments)
  end
  
  def after_create(user)
    UserMailer.notify_new_user(user).deliver
  end
end
