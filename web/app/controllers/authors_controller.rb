class AuthorsController < ApplicationController
  
  # GET /authors
  # GET /authors.:format
  def index
    @authors = Authorship.find :all
    respond_to do |format|
      format.html do
        @programs = Program.find :all, :order => 'name ASC'
      end
      format.xml { render :xml => @authors.to_xml }
    end
  end
  
  # GET /authors/new
  def new
    @authorship = Authorship.new
  end
  
  # POST /authors
  # POST /authors/:id.:format
  def create
    @authorship = Authorship.new(params[:authorship])
    respond_to do |format|
      if @authorship.save
        flash[:notice] = 'Authorship successfully created!'
        format.html { redirect_to authors_path }
        format.xml { head :ok }
      else
        flash[:error] = "There was a problem creating the authorship"
        format.html { render :action => 'new' }
        format.xml { render :xml => @authorship.errors.to_xml }
      end      
    end
  end
  
  # GET /authors/:id
  # GET /authors/:id.:format
  def show
    @active = 'author_dashboard'
    
    @author = User.find_by_urlname(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml { @author.authorships.to_xml }
    end
  end
  
  protected
  
  def active_nav
    @active = 'authors'
  end
end
