module Paper
  
  PRIVACY = {
    :public  => 0,   # DEAFULT - visible by the world; anonymous and logged in users alike
    :private => 1,   # visible only to logged in users
    # :custom  => 2  # visible to an author-speicified list of registered users
  }
  
  module Privacy
    def self.included(base)
      base.class_eval do
        field :privacy, :type => Integer, :default => PRIVACY[:public]
        
        def has_privacy?(p)
          privacy == PRIVACY[p]
        end
        
        def set_privacy!(p)
          self.update_attribute(:privacy, PRIVACY[p])
        end
        
        PRIVACY.each_key do |label|
          define_method("#{label}?") { has_privacy?(label) }
          define_method("#{label}!") { set_privacy!(label) }
        end
      end
    end
  end
end