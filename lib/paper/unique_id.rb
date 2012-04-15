module Paper
  module UniqueId
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        field :unique_id, :type => String, :unique => true
        
        before_create :set_unique_id
      end
    end
    
    module ClassMethods
      def generate_unique_id
        Paper.random_string(8, (?0..?9).to_a)
      end
      
      def find_by_unique_id(id)
        if obj = self.where(:unique_id => id).first
          return obj
        else
          raise Mongoid::Errors::DocumentNotFound
        end
      end
    end
    
    protected 
      
      def set_unique_id
        begin
          self.unique_id = self.class.generate_unique_id
        end while(self.class.find_by_unique_id(self.unique_id))
      end
  end
end