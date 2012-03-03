var lightbox = { 
  html    : '\
  <div id="lightbox" style="display:none;"> \
    <div class="actions"> \
      [ <a href="" class="close">X</a> ] \
    </div> \
    <div class="content"></div> \
  </div>',
  
  overlay : '<div id="lightbox_overlay" style="display:none;"></div>',
  
  show : function(href) {
    $('body').append(lightbox.html);
    $("body").append(lightbox.overlay);
    
    $('#lightbox_overlay').fadeIn(500);
    $('#lightbox').show();
    
    $.ajax({
      url     : href + ".json",
      success : function(data) {
        $('#lightbox .content').html("<img src=\"" + data.url + "\" />");
        
        img = $('#lightbox .content img');
        
        //$('#lightbox').width(img.width());
        //$('#lightbox').height(img.height() + 40);
      }
    });
    
    $('#lightbox .actions a').click(function(e) {
      e.preventDefault();
      $(document).trigger("hide.lightbox");
    });
    
    $(document).bind('hide.lightbox', function(e) {
      lightbox.hide();
    });
    
    $(document).bind('destroy.lightbox', function(e) {
      $("#lightbox").remove();
      $('#lightbox_overlay').remove();

      $(document).unbind('hide.lightbox');

      $('#lightbox .actions a').unbind("click");
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