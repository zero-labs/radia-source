class SpotsController < ApplicationController
  before_filter :login_required, :except => [:index, :show, :unavailable]
  
  # GET /audio/spots
  # GET /audio/spots.:format
  def index
    @spots = Spot.find(:all, :conditions => ["available = ?", true])
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @spots.to_xml }
    end
  end
  
  # GET /audio/spots/:id
  # GET /audio/spots/:id.:format
  def show
    @spot = Spot.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @spot.to_xml }
    end
  end
  
  # GET /audio/spots/new
  def new
    @spot = Spot.new
  end
  
  # POST /audio/spots
  # POST /audio/spots.:format
  def create
    @spot = Spot.new(params[:spot])
    respond_to do |format|
      if @spot.save
        flash[:notice] = 'Spot registered successfully.'
        format.html { redirect_to audio_spot_path(@spot) }
        format.xml { head :ok }
      else
        flash[:error] = 'There were problems creating the spot'
        format.html { render :action => 'new' }
        format.xml { render :xml => @spot.errors.to_xml }
      end
    end
  end
  
  # GET /audio/spots/:id/edit/
  def edit
    @spot = Spot.find(params[:id])
    respond_to do |format|
      format.html # edit.html.erb
      format.xml { render :xml => @spot.to_xml }
    end
  end
  
  # PUT /audio/spots/:id
  # PUT /audio/spots/:id.:format
  def update
    @spot = Spot.find(params[:id])
    respond_to do |format|
      if @spot.update_attributes(params[:spot])
        flash[:notice] = 'Spot updated successfully'
        format.html { redirect_to spot_path(@spot_path) }
        format.xml { head :ok }
      else
        flash[:error] = 'There were problems updating the spot'
        format.html { render :action => 'edit' }
        format.xml { render :xml => @spot.errors.to_xml }
      end
    end
  end
  
  # DELETE /audio/spots/:id
  # DELETE /audio/spots/:id.:format
  def destroy
    @spot = Spot.find(params[:id])
    @spot.destroy
    respond_to do |format|
      flash[:notice] = 'Spot removed'
      format.html { redirect_to spots_path }
      format.xml { head :ok }
    end
  end
  
  # GET /audio/spots/unavailable.:format
  def unavailable
    @spots = Spot.find_all_unavailable
    respond_to do |format|
      format.xml { render :xml => @spots.to_xml }
    end
  end
  
  protected
  
  def active_nav
    @active = 'audio_assets'
  end
end
