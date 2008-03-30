class AuthorsController < ApplicationController
  
  def index
    @authors = Authorship.find :all
    respond_to do |format|
      format.html
      format.xml { render :xml => @authors.to_xml }
    end
  end
  
  def new
    @authorship = Authorship.new
  end
  
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
  
  protected
  
  def active_nav
    @active = 'authors'
  end
end
