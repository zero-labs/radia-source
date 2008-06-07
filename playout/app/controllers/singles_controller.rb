class SinglesController < ApplicationController
  
  # GET /audio/singles.:format
  def index
    @singles = SingleAudioAsset.find(:all)
    respond_to do |format|
      format.xml { render :xml => @singles.to_xml }
    end
  end
  
  # GET /audio/singles/:id.:format
  def show
    @single = SingleAudioAsset.find(params[:id])
    respond_to do |format|
      format.xml { render :xml => @single.to_xml }
    end
  end
  
  # Other views over these resources: Available and Downloading
  
  # GET /audio/singles/available.:format
  def available
    @singles = SingleAudioAsset.find(:all, :conditions => "status = 'available'")
    respond_to do |format|
      format.xml { render :xml => @singles.to_xml }
    end
  end
  
  # GET /audio/singles/downloading.:format
  def downloading
    @singles = SingleAudioAsset.find(:all, :conditions => "status = 'downloading'")
    respond_to do |format|
      format.xml { render :xml => @singles.to_xml }
    end
  end
  
end
