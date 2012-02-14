class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes
    
  include Paper::Markdown
    
  PRIVACY = {
    :public  => 0,   # DEAFULT - visible by the world; anonymous and logged in users alike
    :private => 1,   # visible only to logged in users
    # :custom  => 2  # visible to an author-speicified list of registered users
  }  
    
  belongs_to :user
  has_many :comments, :dependent => :destroy
  
  field :title,        :type => String
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
    user && self.user == user
  end
  
  def can_delete?(user)
    user && (owned_by?(user) || user.has_role?(:delete_posts))
  end
  
  def published?
    self.published_at <= Time.now
  end
  
  def excerpt
    RDiscount.new(self.markdown.split(/\n/).first).to_html
  end
  
  def privacy
    PRIVACY.find { |sym, val| val == self[:privacy] }.try(:first)
  end
  
  protected
  
    # before_save
    # publish now if not specified
    def publish
      self.published_at ||= (self.created_at || Time.now)
    end
end
