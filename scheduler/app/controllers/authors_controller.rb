class AuthorsController < ApplicationController
  
  # GET /authors
  def index
    @authors = User.authors
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @authors.to_xml }
    end
  end
  
  # GET /authors/:id
  # GET /authors/:id.format
  def show
    @author = User.find_author_by_urlname(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @author.to_xml }
    end
  end
  
  protected
  
  def active_nav
    @active = 'author_dashboard'
  end
end
