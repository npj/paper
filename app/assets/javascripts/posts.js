var LightboxNav = function(aLightbox) {
  
  var self = {
    
    html     : '\
      <div class="nav"> \
        <div class="prev"><a href="">&laquo;</a></div> \
        <div class="next"><a href="">&raquo;</a></div> \
      </div>',
      
    lightbox : aLightbox,
    element  : null,
    buttons  : null,
    lastmove : 0,
    delay    : 1000,
    mouse    : false,
    
    init : function() {
      
      self.lightbox.element.prepend(self.html);
      
      self.element = $("#lightbox div.nav");
      self.prev    = $('#lightbox div.nav div.prev');
      self.next    = $('#lightbox div.nav div.next');
            
      $('#lightbox div.nav div').mouseenter(function() {
        self.mouse = true;
      }).mouseleave(function() {
        self.mouse = false;
      });
      
      self.lightbox.element.mousemove(function(e) {
      
        self.lastmove = e.timeStamp;
      
        if(!self.element.data('visible')) {
          self.element.fadeIn(250).delay(self.delay).queue(function() {
            self.hide();
            $(this).dequeue();
          });
          self.element.data('visible', true);
        }
      });
      
      self.lightbox.element.off('hide.lightbox');
      self.lightbox.element.on('hide.lightbox', function(e) {
        e.preventDefault();
        if(!self.mouse) {
          self.lightbox.hide();
        }
      });
      
      self.lightbox.element.on('resize.lightbox', self.resizeAndCenter);
      self.lightbox.element.on('load.lightbox',   self.load);
      
      return self;
    },
    
    resizeAndCenter : function() {
      self.element.css("width", self.lightbox.element.width());
      self.center();
    },
    
    center : function() {
      self.element.css("top", (self.lightbox.element.height() / 2) - (self.element.height() / 2));
    },
    
    hide : function() {
      
      var since = (new Date()).getTime() - self.lastmove;
      
      if(!self.mouse && since >= self.delay) {
        self.element.fadeOut(250).queue(function(e2) {
          self.element.data('visible', false);
          $(this).dequeue();
        });
      }
      else {
        self.element.delay(250).queue(function() {
          self.hide();
          $(this).dequeue();
        });
      }
    },
    
    load : function(event, data) {
      self.setupButton(self.prev, data.prev);
      self.setupButton(self.next, data.next);
      self.resizeAndCenter();
    },
    
    setupButton : function(button, href) {
    
      button.off('click');
    
      if(href.length == 0) {
        button.hide();
        return;
      }
    
      button.attr('href', href);
      button.show();
      button.click(function(e) {
        e.preventDefault();
        self.lightbox.render(href);
      });
    },
  };
  
  return self.init();
};

function openLightbox(event) {
  event.preventDefault();
  
  var lightbox   = new Lightbox();
  var navigation = new LightboxNav(lightbox);
  
  lightbox.show($(event.delegateTarget).attr("href"));
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