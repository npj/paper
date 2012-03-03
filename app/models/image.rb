class Image
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :gallery
  
  field :name
  field :sequence
  
  validates_presence_of :name, :sequence
  
  def path(size)
    "#{self.gallery.name}/#{size}/#{name}"
  end
  
  def url(size)
    AWS::S3::S3Object.url_for(path(size), Paper.config.s3.bucket)
  end
end
