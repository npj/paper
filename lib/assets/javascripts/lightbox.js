var Lightbox = function(opts) { 
  
  var self = {
    
    element_html : '\
      <div id="lightbox" style="display:none;"> \
        <div class="content"></div> \
      </div>',
  
    overlay_html : '\
      <div id="lightbox_overlay" style="display:none;"> \
      </div>',
  
    element       : null,
    overlay       : null,
    content       : null,
    innerContent  : null,
    offsetTop     : 50,
    defaultWidth  : 500,
    defaultHeight : 500,
    renderer      : null,
  
    init : function() {
      
      self.appendTo($('body'));  
      
      self.element = $("#lightbox");
      self.overlay = $("#lightbox_overlay");
      self.content = $("#lightbox div.content");
      
      self.element.click(function(e) {
        e.preventDefault();
        self.element.trigger("hide.lightbox");
      });
      
      self.overlay.click(function(e) {
        e.preventDefault();
        self.element.trigger("hide.lightbox");
      });
      
      self.element.bind('hide.lightbox', function(e) {
        self.hide();
      });
      
      self.element.bind('destroy.lightbox', function(e) {
        self.element.unbind("click");
        self.overlay.unbind("click");

        self.element.remove();
        self.overlay.remove();

        $(this).unbind('hide.lightbox');
        $(this).unbind('destroy.lightbox');
      });
      
      self.renderer = new LightboxRenderer(self);
      
      self.element.trigger('init.lightbox');
      
      return self;
    },
  
    appendTo : function(container) {
      container.append(self.element_html);
      container.append(self.overlay_html);
    },
  
    show : function(url) {
      self.element.css('top', $(window).scrollTop() + self.offsetTop);
      self.render(url);
    },
  
    hide : function() {
      self.element.fadeOut(500).queue(function() {
        $(this).trigger('destroy.lightbox');
        $(this).dequeue();
      });
      $('#lightbox_overlay').fadeOut(500);
    },
  
    setInnerContent : function(content) {
      self.innerContent = content;
      self.content.append(self.innerContent);
    },
  
    render : function(url) {
      self.overlay.fadeIn(500);
      self.renderer.render(url);
    }
  };
  
  return self.init();
};

var LightboxRenderer = function(aLightbox) {
  
  var self = {
    
    lightbox : aLightbox,
    spinner  : null,
    
    render : function(u) {
      $.ajax({
        url     : u,
        success : self.load
      });
    },
  
    load : function(data) {
      
      var spinner  = null;
        
      self.resizeContent();
      self.center();
      self.showProgress();
    
      self.lightbox.element.fadeIn(500);
        
      self.transition(data.content);
      
      self.lightbox.element.trigger('loaded.lightbox', data);
    },
    
    resizeContent : function() {
      
      var width, height;
      
      if(!self.lightbox.innerContent) {
        width  = self.lightbox.defaultWidth;
        height = self.lightbox.defaultHeight;
      }
      else {
        width  = self.lightbox.innerContent.width();
        height = self.lightbox.innerContent.height();
      }
      
      self.lightbox.content.css("width",  width);
      self.lightbox.content.css("height", height);
      
      self.lightbox.element.trigger('resize.lightbox');
    },
    
    showProgress : function() {
    
      var opts = {
        lines     : 12,        // The number of lines to draw
        length    : 30,        // The length of each line
        width     : 20,        // The line thickness
        radius    : 40,        // The radius of the inner circle
        color     : '#000',    // #rgb or #rrggbb
        speed     : 1,         // Rounds per second
        trail     : 100,       // Afterglow percentage
        shadow    : false,     // Whether to render a shadow
        hwaccel   : false,     // Whether to use hardware acceleration
        className : 'spinner', // The CSS class to assign to the spinner
        zIndex    : 2e9,       // The z-index (defaults to 2000000000)
      };
      
      var spinner  = new Spinner(opts).spin();
      
      self.spinner = $(spinner.el);
      self.spinner.css("position", "absolute");
      self.spinner.css("top",  self.lightbox.content.height() / 2);
      self.spinner.css("left", self.lightbox.content.width()  / 2);
    
      self.lightbox.content.append(self.spinner);
    },
    
    transition : function(content) {
      if(self.lightbox.innerContent) {
        self.lightbox.innerContent.fadeOut(500).queue(function() {
          self.lightbox.innerContent.remove();
          self.lightbox.innerContent = null;
          self.transition(content);
          $(this).dequeue();
        });
      }
      else {
        self.setContent(content);
        self.lightbox.innerContent.load(function() {
          self.spinner.remove();
          self.resizeContent();
          self.center();
          self.lightbox.innerContent.fadeIn(500);
        });
      }
    },
     
    setContent : function(content) {
      var content = $(content);
      self.lightbox.setInnerContent(content);
      content.hide();
    },
    
    center : function() {
      self.lightbox.element.css("left", ($(window).width() / 2) - (self.lightbox.content.width() / 2));
    }
  };
  
  return self;
};