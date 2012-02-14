class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  
  include Paper::Markdown
  
  before_validation :set_post, :on => :create
  before_validation :set_path, :on => :create
  
  belongs_to :user
  belongs_to :post
  belongs_to :parent, :class_name => "Comment"
  
  has_many :comments, :foreign_key => :parent_id
  
  validates_presence_of :user_id, :post_id, :path
  
  field :path, :type => Array
  
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
end
