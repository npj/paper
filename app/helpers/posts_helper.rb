module PostsHelper
  def published_at(post)
    post.published_at.in_time_zone.strftime("%A %B %d, %Y &mdash; %H:%M %p %Z").html_safe
  end
  
  def post_comments_count(post)
    pluralize(post.all_comments.where(:deleted_at => nil).visible_to(current_user).count, t("posts.comments_count"))
  end
  
  def post_link(post)
    link_to(t('read_more') + " " + "[" + post_comments_count(post) + "]", post_path(post))
  end
  
  def post_publish_link(post)
    link_to(t('publish'), publish_post_path(post), :method => :post, :confirm => t('posts.publish.confirm'))
  end
  
  def post_edit_link(post)
    link_to(t('edit'), edit_post_path(post))
  end
  
  def post_delete_link(post)
    link_to(t('delete'), post_path(post), :method => :delete, :confirm => t('posts.delete.confirm'))
  end
end
