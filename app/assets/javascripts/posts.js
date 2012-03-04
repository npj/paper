var lightbox = { 
  html    : '\
  <div id="lightbox" style="display:none;"> \
    <div class="content"></div> \
  </div>',
  
  overlay : '<div id="lightbox_overlay" style="display:none;"></div>',
  
  show : function(href) {
    $('body').append(lightbox.html);
    $("body").append(lightbox.overlay);
    
    $('#lightbox_overlay').fadeIn(500);
    
    $.ajax({
      url     : href + ".json",
      success : function(data) {
        $('#lightbox .content').html("<img src=\"" + data.url + "\" />");
        
        img = $('#lightbox .content img');
        
        $("#lightbox").css('top', $("body").scrollTop() + 30);
        img.load(function() {
          $('#lightbox').fadeIn(500);
          $("#lightbox").css("width", $(this).width());
          $("#lightbox").css("height", $(this).height());
          $("#lightbox").css("left", ($(window).width() / 2) - ($(this).width() / 2));
        });
      }
    });
    
    $('#lightbox').click(function(e) {
      e.preventDefault();
      $(document).trigger("hide.lightbox");
    });
    
    $("#lightbox_overlay").click(function(e) {
      e.preventDefault();
      $(document).trigger("hide.lightbox");
    });
    
    $(document).bind('hide.lightbox', function(e) {
      lightbox.hide();
    });
    
    $(document).bind('destroy.lightbox', function(e) {
      $('#lightbox').unbind("click");
      $("#lightbox_overlay").unbind("click");

      $("#lightbox").remove();
      $('#lightbox_overlay').remove();

      $(document).unbind('hide.lightbox');
      $(document).unbind('destroy.lightbox');
      
    });
  },
  
  hide : function() {
    $('#lightbox').fadeOut(500).queue(function() {
      $(document).trigger('destroy.lightbox');
      $(this).dequeue();
    });
    $('#lightbox_overlay').fadeOut(500);
  }
};

function openLightbox(event) {
  event.preventDefault();
  lightbox.show($(event.delegateTarget).attr('href'));
}

$(window).ready(function() {
  $('.info-link').click(function(e) {
    e.preventDefault();
    if($(this).data('visible')) {
      $(this).parent().next().hide();
      $(this).data('visible', false)
    }
    else {
      $(this).parent().next().show();
      $(this).data('visible', true)
    }
  });
  
  $('a[rel=lightbox]').each(function(index, link) {
    $(link).click(openLightbox);
  });
});