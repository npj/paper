module PostsHelper
  def published_at(post)
    post.published_at.in_time_zone.strftime("%B %d, %Y %H:%M %p %Z")
  end
  
  def delete_link(post)
    link_to(t('delete'), post_path(p), :method => :delete, :confirm => t('posts.delete.confirm'))
  end
end
