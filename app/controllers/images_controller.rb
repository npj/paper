class ImagesController < ApplicationController
  
  before_filter :find_image
  
  def show
    respond_to do |format|
      format.html do
        redirect_to(@image.url(:large))
      end
      format.json do
        render :json => { 
          :content => render_to_string(:partial => "image.html", :locals => { :image => @image }), 
          :prev    => (@image.prev ? image_path(@image.prev, :format => :json) : ""), 
          :next    => (@image.next ? image_path(@image.next, :format => :json) : "")
        }
      end
    end
  end
  
  protected
  
    def find_image
      @image = Image.find(params[:id])
    rescue Mongoid::DocumentNotFound
      redirect_to(root_path)
    end
end
