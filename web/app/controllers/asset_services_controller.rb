class AssetServicesController < ApplicationController
  
  # GET /settings/asset_services/new
  def new
    @asset_service = AssetService.new
  end
  
  # POST /settings/asset_services
  # POST /settings/asset_services.:format
  def create
    @asset_service = AssetService.new(params[:asset_service])
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
    @asset_service = AssetService.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @asset_service.to_xml }
    end
  end
  
  # GET /settings/asset_services/:id
  def edit
    @asset_service = AssetService.find(params[:id])
  end
  
  # PUT /settings/asset_services/:id
  # PUT /settings/asset_services/:id.:format
  def update
    @asset_service = AssetService.find(params[:id])
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
    @asset_service = AssetService.find(params[:id])
    @asset_service.destroy
    respond_to do |format|
      flash[:notice] = "Asset service destroyed"
      format.html { redirect_to settings_path }
      format.xml { head :ok }
    end
  end
  
  # POST /settings/asset_services/:id/browser
  def browser
    @asset_service = AssetService.find(params[:id])
    begin
      files = @asset_service.list(params[:password])
      render :partial => 'shared/files', :object => files, :locals => { :service_id => @asset_service.id }
    rescue Exception => e
      render :partial => 'shared/exception', :object => e
    end
  end
  
  protected 
  
  def active_nav
    @active = 'settings'
  end
end
