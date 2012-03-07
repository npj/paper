class Image
  include Mongoid::Document
  include Mongoid::Timestamps
  
  include Paper::Markdown
  
  markdownifies(:raw_caption => :caption)
  
  has_many :all_comments, :as => :commentable, :class_name => 'Comment', :dependent => :destroy
  
  belongs_to :gallery
  
  field :name
  field :sequence
  
  validates_presence_of :name, :sequence
  
  def comments
    self.all_comments.where(:parent_id => nil)
  end
  
  def prev
    gallery.images.where(:sequence => sequence - 1).first
  end
  
  def next
    gallery.images.where(:sequence => sequence + 1).first
  end
  
  def path(size)
    "#{self.gallery.name}/#{size}/#{name}"
  end
  
  def url(size)
    AWS::S3::S3Object.url_for(path(size), Paper.config.s3.bucket)
  end
end
