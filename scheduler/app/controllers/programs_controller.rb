class ProgramsController < ApplicationController  
  before_filter :load_program, :only => [:show, :edit, :update, :destroy]
  before_filter :new_program, :only => :new
  before_filter :new_program_from_params, :only => :create
  
  filter_access_to :all, :attribute_check => true
  filter_access_to :index, :attribute_check => false
  
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
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @program.to_xml }
    end
  end
  
  # GET /programs/new
  def new
    respond_to do |format|
      format.html # new.html.erb
    end
  end
  
  # GET /programs/:id/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end
  
  # POST /programs
  # POST /programs.:format
  def create
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
  
  def load_program
    @program = Program.find_by_urlname(params[:id])
  end
  
  def new_program
    @program = Program.new
  end
  
  def new_program_from_params
    @program = Program.new(params[:program])
  end
end
