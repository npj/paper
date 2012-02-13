class UserObserver < Mongoid::Observer
  def before_create(user)
    user.add_role(:write_comments)
  end
end
