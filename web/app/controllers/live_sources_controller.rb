class LiveSourcesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  
  # GET /settings/live_sources
  # GET /settings/live_sources.:format
  def index
    @live_sources = LiveSource.find(:all)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml { @live_sources.to_xml }
    end
  end
  
  # GET /settings/live_sources/new
  def new
    @live_source = LiveSource.new
  end
  
  # POST /settings/live_sources
  # POST /settings/live_sources.:format
  def create
    @live_source = LiveSource.new(params[:live_source])
    
    respond_to do |format|
      if @live_source.save
        flash[:notice] = "Live source created successfully"
        format.html { redirect_to :action => 'index' }
        format.xml { head :ok }
      else
        flash[:error] = "There were problems creating the live source"
        format.html { render :action => 'new' }
        format.xml { @live_source.to_xml }
      end
    end
  end
  
  # GET /settings/live_sources/edit/:id
  def edit
    @live_source = LiveSource.find(params[:id])
  end
  
  # PUT /settings/live_sources/edit/:id
  # PUT /settings/live_sources/edit/:id.:format
  def update
    @live_source = LiveSource.find(params[:id])
    
    respond_to do |format|
      if @live_source.update_attributes(params[:live_source])
        flash[:notice] = "Live source updated successfully"
        format.html { redirect_to :action => 'index' }
        format.xml { head :ok }
      else
        flash[:errors] = "There were problems updating the live source"
        format.html { render :action => 'edit' }
        format.xml { @live_source.errors.to_xml }
      end
    end
  end
  
  protected
  
  def active_nav
    @active = 'settings'
  end
end
