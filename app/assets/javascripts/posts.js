var lightbox = { 
  html    : '\
  <div id="lightbox" style="display:none;"> \
    <div class="nav"> \
      <div class="prev"><a href="">&laquo;</a></div> \
      <div class="next"><a href="">&raquo;</a></div> \
    </div> \
    <div class="content"></div> \
  </div>',
  
  overlay : '<div id="lightbox_overlay" style="display:none;"></div>',
  lastmove : 0,
  navDelay : 1000,
  mouseNav : false,
  
  show : function(target) {
    $('body').append(lightbox.html);
    $("body").append(lightbox.overlay);
    
    var lb  = $("#lightbox");
    var nav = $('#lightbox div.nav');
    var ol  = $('#lightbox_overlay');
    
    lb.css('top', $(window).scrollTop() + 30);
    ol.fadeIn(500);
    
    this.getImage(target.attr('href'));
    
    nav.mouseenter(function() {
      lightbox.mouseNav = true;
    });
    
    nav.mouseleave(function() {
      lightbox.mouseNav = false;
    });
    
    lb.mousemove(function(e) {
      
      lightbox.lastmove = e.timeStamp;
      
      var navHide = function(e1) {
        
        var since = (new Date()).getTime() - lightbox.lastmove;
        
        if(!lightbox.mouseNav && since >= lightbox.navDelay) {
          $(this).fadeOut(250).queue(function(e2) {
            nav.data('visible', false);
            $(this).dequeue();
          });
        }
        else {
          $(this).delay(250).queue(navHide);
        }
        
        $(this).dequeue();
      };
      
      if(!nav.data('visible')) {
        nav.fadeIn(250).delay(lightbox.navDelay).queue(navHide);
        nav.data('visible', true);
      }
    });
    
    lb.click(function(e) {
      e.preventDefault();
      if(!lightbox.mouseNav) {
        $(document).trigger("hide.lightbox");
      }
    });
    
    ol.click(function(e) {
      e.preventDefault();
      if(!lightbox.mouseNav) {
        $(document).trigger("hide.lightbox");
      }
    });
    
    $(document).bind('hide.lightbox', function(e) {
      lightbox.hide();
    });
    
    $(document).bind('destroy.lightbox', function(e) {
      lb.unbind("click");
      lb.unbind('mousemove');
      ol.unbind("click");

      lb.remove();
      ol.remove();

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
  },
  
  getImage : function(img_url) {
    
    var insertImage = function(data) {
      
      var lightbox = $('#lightbox');
      var nav      = $("#lightbox div.nav")
      
      $('#lightbox .content').html("<img style=\"display:none;\" src=\"" + data.url + "\" />");
      img = $('#lightbox .content img');
      
      img.load(function() {

        lightbox.fadeIn(500);
        lightbox.css("width", $(this).width());
        lightbox.css("height", $(this).height());
        lightbox.css("left", ($(window).width() / 2) - ($(this).width() / 2));
        
        nav.css("width", $(this).width());
        nav.css("top",   ($(this).height() / 2) - (nav.height() / 2));

        img.show();
      });
    };
    
    var loadImage = function(data) {
      
      var nav  = $("#lightbox div.nav")
      
      var prev = $("#lightbox div.nav div.prev a");
      var next = $("#lightbox div.nav div.next a");
      
      var img = $('#lightbox .content img');
      
      if(img.length != 0) {
        img.remove();
      }

      insertImage(data);
      
      prev.unbind('click');
      next.unbind('click');
      
      if(data.prev) {
        prev.attr('href', data.prev);
        prev.show();
        prev.click(function(prevClick) {
          prevClick.preventDefault();
          $.ajax({
            url     : prev.attr('href') + ".json",
            success : loadImage
          });
        });
      } 
      else {
        prev.hide();
      }
      
      if(data.next) {
        next.attr('href', data.next);
        next.show();
        next.click(function(nextClick) {
          nextClick.preventDefault();
          $.ajax({
            url     : next.attr('href') + ".json",
            success : loadImage
          });
        });
      } 
      else {
        next.hide();
      }
    };
    
    $.ajax({
      url     : img_url + ".json",
      success : loadImage
    });
  }
};

function openLightbox(event) {
  event.preventDefault();
  lightbox.show($(event.delegateTarget));
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