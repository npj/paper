class Image
  include Mongoid::Document
  include Mongoid::Timestamps
  
  include Paper::Markdown
  
  THUMBNAILS = {
    :gallery => "156x156",
    :large   => "800x600"
  }
  
  markdownifies(:raw_caption => :caption)
  
  has_many :all_comments, :as => :commentable, :class_name => 'Comment', :dependent => :destroy
  
  belongs_to :gallery
  
  field :key
  field :sequence
  
  validates_presence_of :key, :sequence
  
  after_destroy :destroy_thumbnails
  
  def comments
    self.all_comments.where(:parent_id => nil)
  end
  
  def prev
    gallery.images.where(:sequence => sequence - 1).first
  end
  
  def next
    gallery.images.where(:sequence => sequence + 1).first
  end
  
  def thumb(size)
    return nil unless THUMBNAILS.keys.include?(size)
    Dragonfly[:images].fetch(key).process(:auto_orient).process(:resize, THUMBNAILS[size])
  end
  
  def url(size)
    if size == :full
      AWS::S3::S3Object.url_for(key, Paper.config.s3.bucket)
    else
      thumb(size).url
    end
  end
  
  protected
  
    def destroy_thumbnails
      THUMBNAILS.each do |name, size|
        if t = Thumbnail.where(:job => thumb(name).serialize).first
          t.destroy
        end
      end
    end
end
