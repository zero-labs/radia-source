class ProgramsController < ApplicationController
  
  # GET /programs
  # GET /programs.:format
  def index
    @programs = Program.find(:all, :order => 'name ASC')
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @programs.to_xml }
    end
  end
  
  # GET /programs/program-name
  # GET /programs/program-name.:format
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
  
  # POST /programs/program-name
  # POST /programs/program-name.:format
  def create
    @program = Program.new(params[:program])
    respond_to do |format|
      if @program.save
        flash[:notice] = "Program successfully saved."
        format.html { redirect_to program_path(@program) }
        format.xml { head :ok}
      else
        flash[:error] = "An error occurred."
        format.html { render :action => 'new' }
        format.xml { head :xml => @program.errors.to_xml }
      end
    end
  end
  
  # PUT /programs/program-name
  # PUT /programs/program-name.:format
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
  
  # DELETE /programs/program-name
  # DELETE /programs/program-name.:format
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
