module ApplicationHelper
  def error_messages(object)
    return "" if object.errors.empty?
    content_tag(:ul, :class => "error-messages") do
      object.errors.full_messages.collect do |msg|
        content_tag(:li, msg)
      end.join.html_safe
    end
  end
end
