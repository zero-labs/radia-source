class ProgramsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  
  # GET /programs
  # GET /programs.:format
  def index
    @programs = Program.find(:all, :order => 'name ASC')
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @programs.to_xml }
    end
  end
  
  # GET /programs/:id
  # GET /programs/:id.:format
  def show
    @program = Program.find_by_urlname(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @program.to_xml }
    end
  end
  
  # GET /programs/new
  def new
    @program = Program.new
  end
  
  # GET /programs/edit
  def edit
    @program = Program.find_by_urlname(params[:id])
  end
  
  # POST /programs
  # POST /programs.:format
  def create
    @program = Program.new(params[:program])
    respond_to do |format|
      if @program.save
        flash[:notice] = "Program successfully saved."
        format.html { redirect_to program_path(@program) }
        format.xml { head :ok }
      else
        flash[:error] = "An error occurred."
        format.html { render :action => 'new' }
        format.xml { render :xml => @program.errors.to_xml }
      end
    end
  end
  
  # PUT /programs/:id
  # PUT /programs/:id.:format
  def update
    @program = Program.find_by_urlname(params[:id])  
    
    respond_to do |format|
      if @program.update_attributes(params[:program])
        flash[:notice] = "Program was succesfully updated."
        format.html { redirect_to program_path(@program) }
        format.xml  { head :ok }
      else
        flash[:error] = "An error occurred."
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @program.errors.to_xml }
      end
    end
    
  end
  
  # DELETE /programs/:id
  # DELETE /programs/:id.:format
  def destroy
    @program = Program.find_by_urlname(params[:id])
    @program.destroy
    
    respond_to do |format|
      flash[:notice] = "Program was removed"
      format.html { redirect_to programs_path }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def active_nav
    @active = 'programs'
  end
end
