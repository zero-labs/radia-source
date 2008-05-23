class SinglesController < ApplicationController
  
  # GET /singles.:format
  def index
    @singles = SingleAudioAsset.find(:all)
    respond_to do |format|
      format.xml { render :xml => @singles.to_xml }
    end
  end
  
  # GET /singles/:id.:format
  def show
    @single = SingleAudioAsset.find(params[:id])
    respond_to do |format|
      format.xml { render :xml => @single.to_xml }
    end
  end
  
  # Other views over these resources: Available and Downloading
  
  # GET /singles/available.:format
  def available
    @singles = SingleAudioAsset.find(:all, :conditions => "status = 'available'")
  end
  
  # GET /singles/downloading.:format
  def downloading
    @singles = SingleAudioAsset.find(:all, :conditions => "status = 'downloading'")
  end
  
end
