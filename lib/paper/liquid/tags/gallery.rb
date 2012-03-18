module Paper
  module Liquid
    module Tags
      class Gallery < ::Liquid::Block
        
        SYNTAX = /\'(.+?)\'\s*(.+)?/
        
        def initialize(tag_name, markup, tokens)
          if markup =~ SYNTAX
            @name    = $1.strip
            @size    = ($2 || 'small').strip.to_sym
          end
          super
        end
        
        def render(context)
          result = ''
          row    = 0
          
          unless (gallery = ::Gallery.find_or_create_by(:name => @name, :user_id => context['user_id'])).valid?
            raise gallery.errors.full_messages.join("\n")
          end
          
          context.stack do
            
            gallery.images.order_by([ :sequence, :asc ]).each do |image|
              
              context['gallery_image'] = {
                'prev_url'  => (image.prev ? Paper.url_helpers.image_path(image.prev, :format => :json) : ""),
                'next_url'  => (image.next ? Paper.url_helpers.image_path(image.next, :format => :json) : ""),
                'large_url' => Paper.url_helpers.image_path(image, :format => :json),
                'small_url' => image.url(:gallery)
              }
              
              result << (row == 0 ? %{<div class="row">} : "") 
              result << render_all(@nodelist, context)
              result << (row == 3 ? %{</div>} : "")
                            
              row = (row + 1) % 4
              
              result  
            end
          end
          
          result << (row != 0 ? %{</div>} : "")
          
          %{<div class="gallery">#{result}</div>}
        end
      end
      
      class GalleryImage < ::Liquid::Tag
                
        SYNTAX = /(.+)/
        
        def initialize(tag_name, markup, tokens)
          if markup =~ SYNTAX
            @type = $1.strip
          end
          super
        end
        
        def render(context)
          return nil unless image = context['gallery_image']
          %{<a href="#{image['large_url']}" rel="#{@type}">} +
          "  " + %{<img src="#{image['small_url']}" />} +
          %{</a>}
        end
      end
      
      ::Liquid::Template.register_tag('gallery', Gallery)
      ::Liquid::Template.register_tag('gallery_image', GalleryImage)
    end
  end
end