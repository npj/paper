class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes
    
  PRIVACY = {
    :public  => 0,   # DEAFULT - visible by the world; anonymous and logged in users alike
    :private => 1,   # visible only to logged in users
    # :custom  => 2  # visible to an author-speicified list of registered users
  }  
    
  belongs_to :user
  
  field :title,        :type => String
  field :html,         :type => String
  field :markdown,     :type => String
  field :privacy,      :type => Integer, :default => PRIVACY[:public]
  field :published_at, :type => DateTime
  
  before_save :publish
  before_save :markdownify
  
  def self.for_user(user)
    if user
      self.any_of({ :published_at => { '$lte' => Time.now } }, { :user_id => user.id })
    else
      self.where(:published_at => { '$lte' => Time.now }, :privacy => PRIVACY[:public])
    end
  end
  
  def owned_by?(user)
    self.user == user
  end
  
  def published?
    self.published_at <= Time.now
  end
  
  def privacy
    PRIVACY.find { |sym, val| val == self[:privacy] }.try(:first)
  end
  
  protected
  
    # before_save
    # convert markdown body to html
    def markdownify
      self.html = RDiscount.new(self.markdown || "").to_html
    end
    
    # before_save
    # publish now if not specified
    def publish
      self.published_at ||= (self.created_at || Time.now)
    end
end
