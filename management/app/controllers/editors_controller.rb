class EditorsController < ApplicationController
  
  # GET /schedule/editors
  # GET /schedule/editors.:format
  def index
    @editors = User.editors
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @editors.to_xml }
    end
  end
  
  # GET /schedule/editors/:id
  # GET /schedule/editors/:id.:format
  def show
    @editor = User.find_by_urlname(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @editor.to_xml }
    end
  end
  
  # GET /schedule/editors/new
  def new
    # new.html.erb
  end
  
  # POST /schedule/editors
  # POST /schedule/editors.:format
  def create
    @editor = User.find_by_urlname(params[:id])
    @editor.give_role('editor')
    
    respond_to do |format|
      if @editor.save
        flash[:notice] = "User is now an editor"
        format.html { redirect_to schedule_editors_path }
        format.xml { head :ok }
      else
        flash[:error] = 'There was an error making this user an editor'
        format.html { render :action => 'new' }
        format.xml { render :xml => @editor.errors.to_xml }
      end
    end
  end
  
  # GET /schedule/editors/:id/edit
  def edit
    @editor = User.find_by_urlname(params[:id])
    # edit.html.erb
  end
  
  # PUT /schedule/editors/:id
  # PUT /schedule/editors/:id.:format
  def update
    # TODO
  end
  
  # DELETE /schedule/editors/:id
  # DELETE /schedule/editors/:id.:format
  def destroy
    @editor = User.find_by_urlname(params[:id])
    @editor.take_role('editor')
    
    respond_to do |format|
      flash[:error] = 'User is no longer an editor'
      format.html { redirect_to :action => 'index' }
      format.xml { head :ok }
    end
  end
end
