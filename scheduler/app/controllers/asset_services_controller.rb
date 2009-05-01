class AssetServicesController < ApplicationController
  before_filter :load_asset_service, :only => [:show, :edit, :update, :destroy]
  before_filter :new_asset_service, :only => :new
  before_filter :new_asset_service_from_params, :only => :create
  
  filter_access_to :all, :attribute_check => true
  filter_access_to :index, :attribute_check => false
  
  # GET /settings/asset_services
  # GET /settings/asset_services.:format
  def index
    @asset_services = AssetService.find(:all)
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @asset_services.to_xml }
    end
  end
  
  # GET /settings/asset_services/new
  def new
    respond_to do |format|
      format.html # new.html.erb
    end
  end
  
  # POST /settings/asset_services
  # POST /settings/asset_services.:format
  def create
    respond_to do |format|
      if @asset_service.save
        flash[:notice] = "Asset service created successfully"
        format.html { redirect_to settings_path }
        format.xml { head :ok }
      else
        flash[:error] = "There were problems creating the asset service"
        format.html { render :action => 'new' }
        format.xml { render :xml => @asset_service.errors.to_xml }
      end
    end
  end
  
  # GET /settings/asset_services/:id
  # GET /settings/asset_services/:id.:format
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @asset_service.to_xml }
    end
  end
  
  # GET /settings/asset_services/:id
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end
  
  # PUT /settings/asset_services/:id
  # PUT /settings/asset_services/:id.:format
  def update
    respond_to do |format|
      if @asset_service.update_attributes(params[:asset_service])
        flash[:notice] = "Asset service updated successfully"
        format.html { redirect_to settings_path }
        format.xml { head :ok }
      else
        flash[:error] = "There were problems updating the asset service"
        format.html { render :action => 'edit' }
        format.xml { render :xml => @asset_service.errors.to_xml }
      end
    end
  end
  
  # DELETE /settings/asset_services/:id
  # DELETE /settings/asset_services/:id.:format
  def destroy
    @asset_service.destroy
    respond_to do |format|
      flash[:notice] = "Asset service destroyed"
      format.html { redirect_to settings_asset_services_path }
      format.xml { head :ok }
    end
  end
  
  ### AJAX actions ####
  
  # POST /settings/asset_services/:id/browse
  def browse
    @asset_service = AssetService.find(params[:id])
    begin
      files = @asset_service.list(params[:password])
      render :partial => 'shared/files', :object => files, :locals => { :service => @asset_service }
    rescue Exception => e
      render :partial => 'shared/exception', :object => e
    end
  end
  
  protected 
  
  def active_nav
    @active = 'settings'
  end
  
  def load_asset_service
    @asset_service = AssetService.find(params[:id])
  end
  
  def new_asset_service
    @asset_service = AssetService.new
  end
  
  def new_asset_service_from_params
    @asset_service = AssetService.new(params[:asset_service])
  end
end
