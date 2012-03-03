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
          context.stack do
            
            ::Gallery.user(context['user_id']).find_by_name(@name).images.order_by([ :sequence, :asc ]).each do |img|
              
              context['image'] = {
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
          
          result << (row != 3 ? %{</div>} : "")
          
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
          return nil unless context['image']
          %{<a href="#{context['image']['large_url']}" rel="#{@type}">} +
          "  " + %{<img src="#{context['image']['small_url']}" />} +
          %{</a>}
        end
      end
      
      ::Liquid::Template.register_tag('gallery', Gallery)
      ::Liquid::Template.register_tag('image', Image)
    end
  end
end