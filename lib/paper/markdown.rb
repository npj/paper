module Paper
  module Markdown
    def self.included(base)
      base.class_eval do
        
        @@markdown = { }
        
        before_validation :markdownify
        
        def self.markdownifies(hash)
          hash.each do |attribute, into|
            field into,      :type => String
            field attribute, :type => String
          end
          
          @@markdown.merge!(hash)
        end
         
        protected
        
          # before_validation :on => :save
          # convert markdown body to html
          def markdownify
            @@markdown.each do |attribute, into|
              self[into] = RDiscount.new(self.send(attribute) || "").to_html
            end
          end
          
      end
    end
  end
end
