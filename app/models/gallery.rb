class Gallery 
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  scope :user, lambda { |u| where(:user_id => u) }
  
  belongs_to :user
  has_many :images, :dependent => :destroy
  
  field :name
  
  validates_presence_of :user, :name
  validates_uniqueness_of :name
  
  after_create :reindex
  
  def self.find_by_name(name)
    self.where(:name => name).first
  end
  
  def reindex
    self.images.destroy_all
    seqno = -1
    each_thumbnail do |object|
      self.images.find_or_create_by(:name => object.key.split(/\//).last, :sequence => seqno += 1)
    end
  end
  
  protected
  
    def prefix(thumb)
      "#{self.name}/#{thumb}"
    end
  
    def full(filename)
      "#{prefix(:full)}/#{filename}"
    end
  
    def each_thumbnail(marker = nil, &block)
      objects = AWS::S3::Bucket.objects(Paper.config.s3.bucket, :prefix => prefix(:small), :marker => marker)
      if objects.empty?
        return objects
      else
        objects.select { |obj| obj.key =~ /\.jpg$/i }.each { |obj| yield(obj) }
        each_thumbnail(objects.last.key, &block)
      end
    end
end
