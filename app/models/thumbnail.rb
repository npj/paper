class Thumbnail
  include Mongoid::Document
  
  field :job
  field :uid
  
  after_destroy :delete_data
  
  protected
  
    def delete_data
      Dragonfly[:images].datastore.destroy(self.uid)
    end
end
