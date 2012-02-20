module CommentsHelper
  def comment_date(comment)
    comment.created_at.in_time_zone.strftime("%B %d, %Y &mdash; %H:%M %p %Z").html_safe
  end
end
