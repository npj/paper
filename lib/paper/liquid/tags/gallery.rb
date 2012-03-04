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
            
            gallery.images.order_by([ :sequence, :asc ]).each do |img|
              
              context['image'] = {
                'prev_url'  => (img.prev ? Paper.url_helpers.image_path(img.prev) : ""),
                'next_url'  => (img.next ? Paper.url_helpers.image_path(img.next) : ""),
                'large_url' => Paper.url_helpers.image_path(img),
                'small_url' => img.url(:small)
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
      
      class Image < ::Liquid::Tag
                
        SYNTAX = /(.+)/
        
        def initialize(tag_name, markup, tokens)
          if markup =~ SYNTAX
            @type = $1.strip
          end
          super
        end
        
        def render(context)
          return nil unless image = context['image']
          %{<a href="#{image['large_url']}" rel="#{@type}">} +
          "  " + %{<img src="#{image['small_url']}" />} +
          %{</a>}
        end
      end
      
      ::Liquid::Template.register_tag('gallery', Gallery)
      ::Liquid::Template.register_tag('image', Image)
    end
  end
end