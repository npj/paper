module Paper
  
  def self.config
    Config.instance
  end
  
  class Config
    include Singleton
    
    protected
    
      def read(path)
        YAML.load(ERB.new(File.read(path)).result)
      end
    
      def path
        File.join(File.dirname(__FILE__), '..', 'paper.yml')
      end
    
      def initialize
        define_accessors(self, read(path)[Rails.env])
      end
      
    private
        
      def define_accessors(object, hash)
        hash.each do |key, value|
          if value.is_a?(Hash)
            Object.new.tap do |child|
              define_accessors(child, value)
              object.class_eval { define_method(key) { child } }
            end
          else
            object.class_eval { define_method(key) { value } }
          end
        end
      end
  end
end

ActionMailer::Base.default_url_options = { :host => Paper.config.host }
Time.zone = Paper.config.time_zone