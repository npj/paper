module Paper
  module Liquid
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        class_attribute :liquify_attributes
        before_validation :liquify
      end
      
      Paper::Liquid::Tags::Gallery
    end
    
    module ClassMethods
      
      def liquifies(hash, filters = [ ])
        hash.each do |attribute, into|
          field attribute, :type => String
          field into,      :type => BSON::Binary
        end
        
        self.liquify_attributes ||= { }
        self.liquify_attributes.merge!(hash)
        
        filters.each { |filter| ::Liquid::Template.register_filter(filter) }
      end
    end
    
    protected

      # before_validation
      # process and save liquid templates
      def liquify
        self.class.liquify_attributes.each do |attribute, into|
          self[into] = BSON::Binary.new(Marshal.dump(::Liquid::Template.parse(self.send(attribute) || "")))
        end
      end
  end
end
