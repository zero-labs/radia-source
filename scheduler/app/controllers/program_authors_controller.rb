class ProgramAuthorsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  before_filter :get_program
  
  # GET /programs/:program_id/authors
  # GET /programs/:program_id/authors.:format
  def index
    @authorships = @program.authorships
    respond_to do |format|
      format.html { @programs = Program.find :all, :order => 'name ASC' } # index.html.erb
      format.xml { render :xml => @authorships.to_xml }
    end
  end
  
  # GET /programs/:program_id/authors/new
  def new
    @authorship = Authorship.new
  end
  
  # POST /programs/:program_id/authors
  # POST /programs/:program_id/authors.:format
  def create
    @authorship = Authorship.new(params[:authorship])
    respond_to do |format|
      if @authorship.save
        flash[:notice] = 'Authorship successfully created!'
        format.html { redirect_to program_authors_path(@program) }
        format.xml { head :ok }
      else
        flash[:error] = "There was a problem creating the authorship"
        format.html { render :action => 'new' }
        format.xml { render :xml => @authorship.errors.to_xml }
      end      
    end
  end
  
  
  # GET /programs/:program_id/authors/:id
  # GET /programs/:program_id/authors/:id.:format
  def show
    user = User.find_by_urlname(params[:id])
    @authorship = @program.authorships.find_by_user_id(user)

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @authorship.to_xml }
    end
  end
  
  # GET /programs/:program_id/authors/:id/edit
  def edit
    user = User.find_by_urlname(params[:id])
    @authorship = @program.authorships.find_by_user_id(user)
  end
  
  # PUT /programs/:program_id/authors/:id
  # PUT /programs/:program_id/authors/:id.:format
  def update
     user = User.find_by_urlname(params[:id])
     @authorship = @program.authorships.find_by_user_id(user)
     
     respond_to do |format|
       if @authorship.update_attributes(params[:authorship])
         flash[:notice] = 'Authorship successfully updated!'
         format.html { redirect_to program_authors_path(@program) }
         format.xml { head :ok }
       else
         flash[:error] = "There was a problem updating the authorship"
         format.html { render :action => 'new' }
         format.xml { render :xml => @authorship.errors.to_xml }
       end      
     end
  end
  
  # DELETE /programs/:program_id/authors/:id
  # DELETE /programs/:program_id/authors/:id.:format
  def destroy
    user = User.find_by_urlname(params[:id])
    @authorship = @program.authorships.find_by_user_id(user)
    @authorship.destroy
    
    respond_to do |format|
      flash[:notice] = 'Authorship destroyed'
      format.html { redirect_to program_authors_path(@program) }
      format.xml { head :ok }
    end
  end
  
  
  protected
  
  def get_program
    @program = Program.find_by_urlname(params[:program_id])
  end
  
  def active_nav
    @active = 'programs'
  end
end
