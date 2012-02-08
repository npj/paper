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
        read(path)[Rails.env].each do |key, value|
          class_eval { define_method(key) { value } }
        end
      end
  end
end

ActionMailer::Base.default_url_options = { :host => Paper.config.host }
Time.zone = Paper.config.time_zone