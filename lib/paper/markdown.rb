module Paper
  module Markdown
    def self.included(base)
      base.class_eval do
        before_validation :markdownify
        
        field :html,     :type => String
        field :markdown, :type => String
        
        protected
        
          # before_validation :on => :save
          # convert markdown body to html
          def markdownify
            self.html = RDiscount.new(self.markdown || "").to_html
          end
          
      end
    end
  end
end
