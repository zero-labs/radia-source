class SinglesController < ApplicationController
  before_filter :login_required, :except => [:index, :show, :unavailable]
  
  # GET /audio/singles
  # GET /audio/singles.:format
  def index
    @single_audio_assets = SingleAudioAsset.find(:all)
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @single_audio_assets.to_xml }
    end
  end
  
  # GET /audio/singles/:id
  # GET /audio/singles/:id.:format
  def show
    @single_audio_asset = SingleAudioAsset.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @single_audio_asset.to_xml }
    end
  end
  
  # GET /audio/singles/new
  def new
    @single_audio_asset = SingleAudioAsset.new
  end
  
  # POST /audio/singles
  # POST /audio/singles.:format
  def create
    @single_audio_asset = SingleAudioAsset.new(params[:single_audio_asset])
    respond_to do |format|
      if @single_audio_asset.save
        flash[:notice] = 'Single registered successfully. It will be downloaded soon.'
        format.html { redirect_to audio_single_path(@single_audio_asset) }
        format.xml { head :ok }
      else
        flash[:error] = 'There were problems creating the single'
        format.html { render :action => 'new' }
        format.xml { render :xml => @single_audio_asset.errors.to_xml }
      end
    end
  end
  
  # GET /audio/singles/:id/edit/
  def edit
    @single_audio_asset = SingleAudioAsset.find(params[:id])
    respond_to do |format|
      format.html # edit.html.erb
      format.xml { render :xml => @single_audio_asset.to_xml }
    end
  end
  
  # PUT /audio/singles/:id
  # PUT /audio/singles/:id.:format
  def update
    @single_audio_asset = SingleAudioAsset.find(params[:id])
    respond_to do |format|
      if @single_audio_asset.update_attributes(params[:single_audio_asset])
        flash[:notice] = 'Single updated successfully'
        format.html { redirect_to single_path(@single_path) }
        format.xml { head :ok }
      else
        flash[:error] = 'There were problems updating the single'
        format.html { render :action => 'edit' }
        format.xml { render :xml => @single_audio_asset.errors.to_xml }
      end
    end
  end
  
  # DELETE /audio/singles/:id
  # DELETE /audio/singles/:id.:format
  def destroy
    @single_audio_asset = SingleAudioAsset.find(params[:id])
    @single_audio_asset.destroy
    respond_to do |format|
      flash[:notice] = 'Single removed'
      format.html { redirect_to singles_path }
      format.xml { head :ok }
    end
  end
  
  # GET /audio/singles/unavailable.:format
  def unavailable
    @single_audio_assets = SingleAudioAsset.find_all_unavailable
    respond_to do |format|
      format.xml { render :xml => @single_audio_assets.to_xml }
    end
  end
  
  protected
  
  def active_nav
    @active = 'audio_assets'
  end
end
