# a comment's default privacy is public
# a reply to a private comment is always private
# a private comment cannot become public (maybe change in the future)
class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  
  include Paper::Markdown
  include Paper::Privacy
  
  before_validation :set_post,       :on => :create
  before_validation :set_path,       :on => :create
  before_validation :set_visible_to, :on => :create
  
  before_save  :inherit_privacy
  after_save   :pass_down_privacy
  after_create :add_user_to_parent_visible
  
  belongs_to :user
  belongs_to :post
  belongs_to :parent, :class_name => "Comment"
  
  has_many :comments, :foreign_key => :parent_id
  
  validates_presence_of :user_id, :post_id, :path, :visible_to
  validates_presence_of :body
  
  field :path,       :type => Array
  field :visible_to, :type => Array, :default => [ ]
  
  alias_method :body, :markdown
  
  def self.visible_to(user)
    if user
      any_of({ :privacy => Paper::PRIVACY[:public] }, { :visible_to => { '$in' => [ user.id ] } })
    else
      where(:privacy => Paper::PRIVACY[:public])
    end
  end
  
  protected
    
    # before_validation :on => :create
    # if there is a parent, set the post
    # to the parent's post
    def set_post
      if self.parent
        self.post = self.parent.post
      end
    end
  
    # before_validation :on => :create
    # the path is a list of ids from the root
    # to this node which includes this node
    def set_path
      if self.parent
        self.path = self.parent.path + [ self.id ]
      else
        self.path = [ self.id ]
      end
    end
    
    # before_validation, :on => :create
    # set the default list of users who can 
    # view this comment
    # a comment is always visible to the owner
    # a comment is always visible to the post owner
    # a comment is always visible to the parent comment owner
    def set_visible_to
      
      if self.user
        self.visible_to << self.user.id
      end
      
      if self.post
        self.visible_to |= [ self.post.user.id ]
        if self.parent
          self.visible_to |= [ self.parent.user.id ]
        end
      end
    end
    
     # set privacy to private if parent or post is private
    def inherit_privacy
      if self.parent.try(:private?) || self.post.try?(:private?)
        self.private! unless self.private?
      end
    end
    
    # after_save
    # if our privacy has changed to private, set children to private
    def pass_down_privacy
      if self.changes.has_key?('privacy') && self.private?
        self.comments.each { |child| child.private! unless child.private? }
      end
    end
    
    # after_create
    # a comment is always visible to the owners of child comments
    def add_user_to_parent_visible(p = self.parent)
      if p
        p.visible_to |= [ self.user.id ]
        p.save
        add_user_to_parent_visible(p.parent)
      end
    end
end
