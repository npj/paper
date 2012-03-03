class ImagesController < ApplicationController
  
  before_filter :find_image
  
  def show
    redirect_to(@image.url(:large))
  end
  
  protected
  
    def find_image
      @image = Image.find(params[:id])
    rescue Mongoid::DocumentNotFound
      redirect_to(root_path)
    end
end
