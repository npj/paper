module Paper
  module Markdown
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        class_attribute :markdown_attributes
        before_validation :markdownify
      end
    end
    
    module ClassMethods
      def markdownifies(hash)
        hash.each do |attribute, into|
          field into,      :type => String
          field attribute, :type => String
        end
        
        self.markdown_attributes ||= { }
        self.markdown_attributes.merge!(hash)
      end
    end
    
    protected
    
      # before_validation
      # convert markdown attributes to html
      def markdownify
        self.class.markdown_attributes.each do |attribute, into|
          self[into] = RDiscount.new(self.send(attribute) || "").to_html
        end
      end
  end
end
