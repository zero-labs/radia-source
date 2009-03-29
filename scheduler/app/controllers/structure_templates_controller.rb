class StructureTemplatesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  
  # GET /schedule/broadcasts/templates
  # GET /schedule/broadcasts/templates.:format
  def index
    @structure_templates = StructureTemplate.find(:all, :order => :name)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @structure_templates.to_xml }
    end
  end
  
  # GET /schedule/broadcasts/templates/:id
  # GET /schedule/broadcasts/templates/:id.:format
  def show
    @structure_template = StructureTemplate.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @structure_template.to_xml }
    end
  end
  
  # GET /schedule/broadcasts/templates/new
  def new
    @structure_template = StructureTemplate.new
  end
  
  # POST /schedule/broadcasts/templates
  # POST /schedule/broadcasts/templates.:format
  def create
    @structure_template = StructureTemplate.new(params[:structure_template])
    
    respond_to do |format|
      if @structure_template.save
        flash[:notice] = "Structure template successfully created"
        format.html { redirect_to schedule_structure_templates_path }
        format.xml { head :ok }
      else
        flash[:error] = "There were problems creating the structure template."
        format.html { render :action => 'new' }
        format.xml { render :xml => @structure_template.errors.to_xml }
      end
    end
  end
  
  # GET /schedule/broadcasts/templates/edit
  def edit
    @structure_template = StructureTemplate.find(params[:id])
  end
  
  # PUT /schedule/broadcasts/templates/:id
  # PUT /schedule/broadcasts/templates/:id.:format
  def update
    @structure_template = StructureTemplate.find(params[:id])
    
    respond_to do |format|
      if @structure_template.update_attributes(params[:structure_template])
        flash[:notice] = "Structure template successfully updated"
        format.html { redirect_to schedule_structure_template_path(@structure_template) }
        format.xml { head :ok }
      else
        flash[:error] = "There were problems updating the structure template"
        format.html { render :action => 'edit' }
        format.xml { render :xml => @structure_template.errors.to_xml }
      end
    end
  end
  
  # DELETE /schedule/broadcasts/templates/:id
  # DELETE /schedule/broadcasts/templates/:id.:format
  def destroy
    @structure_template = StructureTemplate.find(params[:id])
    @structure_template.destroy
    
    respond_to do |format|
      flash[:notice] = "Structure template was removed"
      format.html { redirect_to schedule_structure_templates_path }
      format.xml { head :ok }
    end
  end
  
  # AJAX methods
  
  # POST /schedule/broadcasts/templates/:id/show_segment
  def show_segment
    @structure_template = StructureTemplate.find(params[:id])
    @segment = Segment.new
    render :partial => params[:kind]
  end
  
  # POST /schedule/broadcasts/templates/:id/create_segment
  def create_segment
    @structure = StructureTemplate.find(params[:id]).structure
    
    render :update do |page|
      if @structure.add_segment(Segment.new(params[:segment]))
        flash[:notice] = 'structure segment created successfully'
      else
        flash[:error] = 'There were errors creating the structure segment'
      end
      page.replace_html 'segment', :text => ''
      page.replace_html 'structure', :partial => 'structure', :object => @structure
    end
  end
  
  protected
  
  def active_nav
    @active = 'schedule'
  end
end
