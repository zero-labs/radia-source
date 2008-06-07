class SpotsController < ApplicationController
  # GET /audio/spots.:format
  def index
    @spots = SpotAudioAsset.find(:all)
    respond_to do |format|
      format.xml { render :xml => @spots.to_xml }
    end
  end
  
  # GET /audio/spots/:id.:format
  def show
    @spot = SpotAudioAsset.find(params[:id])
    respond_to do |format|
      format.xml { render :xml => @spot.to_xml }
    end
  end
  
  # Other views over these resources: Available and Downloading
  
  # GET /audio/spots/available.:format
  def available
    @spots = SpotAudioAsset.find(:all, :conditions => "status = 'available'")
    respond_to do |format|
      format.xml { render :xml => @spots.to_xml }
    end
  end
  
  # GET /audio/spots/downloading.:format
  def downloading
    @spots = SpotAudioAsset.find(:all, :conditions => "status = 'downloading'")
    respond_to do |format|
      format.xml { render :xml => @spots.to_xml }
    end
  end
end
