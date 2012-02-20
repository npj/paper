module PostsHelper
  def published_at(post)
    post.published_at.in_time_zone.strftime("%A %B %d, %Y &mdash; %H:%M %p %Z").html_safe
  end
  
  def delete_link(post)
    link_to(t('delete'), post_path(p), :method => :delete, :confirm => t('posts.delete.confirm'))
  end
end
