# a comment's default privacy is public
# a reply to a private comment is always private
# a private comment cannot become public (maybe change in the future)
class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  
  include Paper::Markdown
  include Paper::Privacy
  
  markdownifies(:markdown => :html)
  
  before_validation :set_commentable, :on => :create
  before_validation :set_path,        :on => :create
  before_validation :set_visible_to,  :on => :create
  
  before_save  :inherit_privacy
  after_save   :pass_down_privacy
  
  belongs_to :user
  belongs_to :commentable, :polymorphic => true
  belongs_to :parent, :class_name => "Comment"
  
  has_many :comments, :foreign_key => :parent_id
  
  validates_presence_of :user_id, :commentable_id, :commentable_type, :path, :visible_to
  validates_presence_of :body
  
  field :path,       :type => Array
  field :visible_to, :type => Array,    :default => [ ]
  field :deleted_at, :type => DateTime, :default => nil
  
  alias_method :body, :markdown
  
  def self.visible_to(user)
    if user
      any_of({ :privacy => Paper::PRIVACY[:public] }, { :visible_to => [ user.id ] })
    else
      where(:privacy => Paper::PRIVACY[:public])
    end
  end
  
  def owned_by?(u)
    u && u == self.user
  end
  
  def can_delete?(u)
    !deleted? && (owned_by?(u) || u.has_role?(:delete_comments))
  end
  
  def deleted?
    !!self.deleted_at
  end
  
  def has_comments?(include_deleted = false)
    if include_deleted
      self.comments.count > 0
    else
      self.comments.where(:deleted_at => nil).count > 0
    end
  end
  
  def delete!
    update_attribute(:deleted_at, Time.now)
  end
  
  protected
    
    # before_validation :on => :create
    # if there is a parent, set the commentable
    # to the parent's commentable
    def set_commentable
      if self.parent
        self.commentable = self.parent.commentable
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
    # a comment is always visible to the commentable owner
    # a comment is always visible to the parent comment owner
    def set_visible_to
      
      if self.user
        self.visible_to << self.user.id
      end
      
      if self.commentable
        self.visible_to |= [ self.commentable.user.id ]
        if self.parent
          self.visible_to |= [ self.parent.user.id ]
        end
      end
    end
    
    # a comment is always visible to the owners of child comments
    # set privacy to private if parent or commentable is private
    def inherit_privacy
      if parent
        parent.visible_to |= [ self.user_id ]
        parent.save
      end
      
      if self.parent.try(:private?) || self.commentable.try(:private?)
        self.private!
      end
    end
    
    # after_save
    # if our privacy has changed to private, set children to private
    def pass_down_privacy
      if self.changes.has_key?('privacy') && self.private?
        self.comments.each { |c| c.private! }
      end
    end
end
