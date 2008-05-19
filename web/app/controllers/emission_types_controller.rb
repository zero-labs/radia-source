class EmissionTypesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  
  # GET /schedule/emissions/types
  # GET /schedule/emissions/types.:format
  def index
    @emission_types = EmissionType.find(:all, :order => :name)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @emission_types.to_xml }
    end
  end
  
  # GET /schedule/emissions/types/:id
  # GET /schedule/emissions/types/:id.:format
  def show
    @emission_type = EmissionType.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @emission_type.to_xml }
    end
  end
  
  # GET /schedule/emissions/types/new
  def new
    @emission_type = EmissionType.new
  end
  
  # POST /schedule/emissions/types
  # POST /schedule/emissions/types.:format
  def create
    @emission_type = EmissionType.new(params[:emission_type])
    
    respond_to do |format|
      if @emission_type.save
        flash[:notice] = "Emission type successfully created"
        format.html
        format.xml { head :ok }
      else
        flash[:error] = "There were problems creating the emission type"
        format.html { render :action => 'new' }
        format.xml { render :xml => @emission_type.errors.to_xml }
      end
    end
  end
  
  # GET /schedule/emissions/types/edit
  def edit
    @emission_type = EmissionType.find(params[:id])
  end
  
  # PUT /schedule/emissions/types/:id
  # PUT /schedule/emissions/types/:id.:format
  def update
    @emission_type = EmissionType.find(params[:id])
    
    respond_to do |format|
      if @emission_type.update_attributes(params[:emission_type])
        flash[:notice] = "Emission type successfully updated"
        format.html { redirect_to schedule_emission_type_path(@emission_type) }
        format.xml { head :ok }
      else
        flash[:error] = "There were problems updating the emission type"
        format.html { render :action => 'edit' }
        format.xml { render :xml => @emission_type.errors.to_xml }
      end
    end
  end
  
  # DELETE /schedule/emissions/types/:id
  # DELETE /schedule/emissions/types/:id.:format
  def destroy
    @emission_type = EmissionType.find(params[:id])
    @emission_type.destroy
    
    respond_to do |format|
      flash[:notice] = "Emission type was removed"
      format.html { redirect_to schedule_emission_types_path }
      format.xml { head :ok }
    end
  end
  
  # AJAX methods
  
  # POST /schedule/emissions/types/show_bloc_element
  def show_bloc_element
    @emission_type = EmissionType.find(params[:id])
    @bloc_element = BlocElement.new
    render :partial => params[:kind]
  end
  
  # POST /schedule/emissions/types/create_bloc_element
  def create_bloc_element
    @bloc = EmissionType.find(params[:id]).bloc
    
    render :update do |page|
      if @bloc.add_element(BlocElement.new(params[:bloc_element]))
        flash[:notice] = 'Bloc element created successfully'
      else
        flash[:error] = 'There were errors creating the bloc element'
      end
      page.replace_html 'bloc_element', :text => ''
      page.replace_html 'bloc', :partial => 'bloc', :object => @bloc
    end
  end
  
  protected
  
  def active_nav
    @active = 'schedule'
  end
end
