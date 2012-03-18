class Gallery 
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  scope :user, lambda { |u| where(:user_id => u) }
  
  belongs_to :user
  has_many :images, :dependent => :destroy
  
  field :name
  
  validates_presence_of :user, :name
  validates_uniqueness_of :name
  
  validate :ensure_exists
  
  after_create :reindex
  
  def self.find_by_name(name)
    self.where(:name => name).first
  end
  
  def can_reindex?(u)
    u && (self.user == u || u.has_role?(:reindex_galleries))
  end
  
  def can_delete?(u)
    u && (self.user == u || u.has_role?(:delete_galleries))
  end
  
  def reindex
    self.images.destroy_all
    seqno = -1
    each_image do |object|
      unless image = self.images.where(:key => object.key).first
        self.images.create({
          :key      => object.key,
          :sequence => seqno += 1
        })
      end
    end
  end
  
  protected
  
    # validate
    def ensure_exists
      unless AWS::S3::S3Object.exists?(self.name + "/", Paper.config.s3.bucket)
        errors.add(:base, "gallery does not exist")
      end
    end
  
    def prefix(thumb)
      "#{self.name}/#{thumb}"
    end
  
    def full(filename)
      "#{prefix(:full)}/#{filename}"
    end
  
    def each_image(marker = nil, &block)
      objects = AWS::S3::Bucket.objects(Paper.config.s3.bucket, :prefix => prefix(:full), :marker => marker)
      if objects.empty?
        return objects
      else
        objects.select { |obj| obj.key =~ /\.jpg$/i }.each { |obj| yield(obj) }
        each_image(objects.last.key, &block)
      end
    end
end
