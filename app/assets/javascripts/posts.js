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
    
    var requestImage = function(href) {
      $.ajax({
        url     : href + ".json",
        success : loadImage
      });
    };
    
    var showProgress = function(container) {
      
      var opts = {
        lines: 12, // The number of lines to draw
        length: 30, // The length of each line
        width: 20, // The line thickness
        radius: 40, // The radius of the inner circle
        color: '#000', // #rgb or #rrggbb
        speed: 1, // Rounds per second
        trail: 100, // Afterglow percentage
        shadow: false, // Whether to render a shadow
        hwaccel: false, // Whether to use hardware acceleration
        className: 'spinner', // The CSS class to assign to the spinner
        zIndex: 2e9, // The z-index (defaults to 2000000000)
      };
      
      var spinner = new Spinner(opts).spin();
      var element = spinner.el;
      
      $(element).css("position", "absolute");
      $(element).css("top", container.height() / 2);
      $(element).css("left", container.width() / 2);
      
      container.append(element);
      
      return $(element);
    };
    
    var appendOverlay = function(content, img) {
      
      var html   = '<div class="image-overlay"></div>';
      var width  = 500;
      var height = 500;
      
      if(img.length > 0) {
        width  = img.width();
        height = img.height();
      }
      
      content.append(html);
      
      overlay = content.find("div.image-overlay");
            
      overlay.css("width",  width);
      overlay.css("height", height);
      
      content.css("width",  width);
      content.css("height", height);
      
      return overlay;
    };
    
    var appendImage = function(content, href) {
      
      var html = '<img style="display:none;" />';
      var img  = null;
      
      content.append(html);
      
      img = content.find("img");
      img.attr("src", href);
      
      return img;
    };
    
    var resize = function(element, reference) {
      element.css("width",  reference.width());
      element.css("height", reference.height());
    };
    
    var resizeAndPosition = function(element, reference) {
      
      var nav = $("#lightbox div.nav");

      resize(element, reference);
      element.css("left", ($(window).width() / 2) - (reference.width() / 2));
      
      nav.css("width", reference.width());
      nav.css("top",   (reference.height() / 2) - (nav.height() / 2));
    };
    
    var transition = function(lightbox, content, img, overlay, href, spinner) {
      img = appendImage(content, href);
      img.load(function() {
        spinner.remove();
        resize(overlay, $(this));
        resizeAndPosition(lightbox, $(this));
        overlay.fadeOut(500).queue(function() {
          $(this).remove();
        });
        img.fadeIn(500);
      });
    };
    
    var insertImage = function(data) {
      
      var lightbox = $('#lightbox');
      var img      = $('#lightbox .content img');
      var content  = $("#lightbox .content");
      var overlay  = appendOverlay(content, img);
      var spinner  = null;
            
      resizeAndPosition(lightbox, overlay);
      
      overlay.fadeIn(500);      
      lightbox.fadeIn(500);  
            
      spinner = showProgress(content);      
            
      if(img.length != 0) {
        img.fadeOut(500).queue(function() {
          $(this).remove();
          transition(lightbox, content, img, overlay, data.url, spinner);
        });
      }
      else {
        transition(lightbox, content, img, overlay, data.url, spinner);
      }
    };
    
    var setupButton = function(button, href) {
      
      button.unbind('click');
      
      if(href.length == 0) {
        button.hide();
        return;
      }
      
      button.attr('href', href);
      button.show();
      button.click(function(e) {
        e.preventDefault();
        requestImage(href);
      });
    };
    
    var loadImage = function(data) {
      
      insertImage(data);
      
      setupButton($("#lightbox div.nav div.prev a"), data.prev);
      setupButton($("#lightbox div.nav div.next a"), data.next);
    };
    
    requestImage(img_url);
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