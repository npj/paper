class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes
    
  include Paper::Markdown
  include Paper::Liquid
  include Paper::Privacy
  
  markdownifies({ 
    :raw_body    => :markdown,
    :raw_excerpt => :excerpt_markdown
  })
  
  liquifies({
    :markdown         => :template,
    :excerpt_markdown => :excerpt_template
  })
  
  belongs_to :user
  has_many :all_comments, :class_name => 'Comment', :dependent => :destroy
  
  field :title,        :type => String
  field :published_at, :type => DateTime
  
  before_save :publish
  after_save  :pass_down_privacy
  
  def self.for_user(user)
    if user
      self.any_of({ :published_at => { '$lte' => Time.now } }, { :user_id => user.id })
    else
      self.where(:published_at => { '$lte' => Time.now }, :privacy => Paper::PRIVACY[:public])
    end
  end
  
  def comments
    self.all_comments.where(:parent_id => nil)
  end
  
  def owned_by?(user)
    user && self.user == user
  end
  
  def can_publish?(user)
    !self.published? && (owned_by?(user) || user.has_role?(:publish_posts))
  end
  
  def can_edit?(user)
    owned_by?(user)
  end
  
  def can_delete?(user)
    user && (owned_by?(user) || user.has_role?(:delete_posts))
  end
  
  def published?
    self.published_at <= Time.now
  end
  
  def publish!
     self.published_at = Time.now
     self.save
  end
  
  def raw_excerpt
    self[:raw_excerpt].present? ? self[:raw_excerpt] : (self[:raw_body] || "").split(/\n/).first
  end
  
  def excerpt_template
    Marshal.load(self[:excerpt_template])
  end
  
  def template
    Marshal.load(self[:template])
  end
  
  def excerpt
    excerpt_template.render('user_id' => user_for_liquid)
  end
  
  def html
    template.render('user_id' => user_for_liquid)
  end
  
  protected
  
    def user_for_liquid
      user.id.to_s
    end
  
    # before_save
    # publish now if not specified
    def publish
      self.published_at ||= (self.created_at || Time.now)
    end
    
    # after_save
    # if our privacy has changed to private, set comments to private
    def pass_down_privacy
      if self.changes.has_key?('privacy') && self.private?
        self.comments.each { |comment| comment.private! }
      end
    end
end
