$(window).ready(function() {
  $(".reply-link").each(function(index, link) {
    $(link).click(function(e) {
      e.preventDefault();
      $("#" + $(link).data('form-id')).show();
      $("#" + $(link).data('form-id')).find("textarea").focus();
    });
  });
  
  $(".form.reply .cancel").each(function(index, link) {
    $(link).click(function(e) {
      e.preventDefault();
      $("#" + $(link).data("form-id")).hide();
    });
  });
  
  $(".comment-collapse").each(function(index, link) {
    $(link).click(function(e) {
      e.preventDefault();
      
      comment_id = $(link).parent().data("id");
      
      if($(link).data('collapsed')) {
        $(".comment[data-parent-id=" + comment_id + "]").each(function(index, comment) {
          $(comment).show();
        });
        
        $(".comment[data-id=" + comment_id + "] > div.collapsable").each(function(index, comment) {
          $(comment).show();
        });
        
        $(link).html("-");
        $(link).data("collapsed", false);
      }
      else {      
        $(".comment[data-parent-id=" + comment_id + "]").each(function(index, comment) {
          $(comment).hide();
        });
        
        $(".comment[data-id=" + comment_id + "] > div.collapsable").each(function(index, comment) {
          $(comment).hide();
        });
        
        $(link).html("+");
        $(link).data("collapsed", true);
      }
    });
  });
})