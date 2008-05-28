class SinglesController < ApplicationController
  before_filter :login_required, :except => [:index, :show, :unavailable]
  
  # GET /audio/singles
  # GET /audio/singles.:format
  def index
    @singles = Single.find(:all, :conditions => ["available = ?", true])
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @singles.to_xml }
    end
  end
  
  # GET /audio/singles/:id
  # GET /audio/singles/:id.:format
  def show
    @single = Single.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @single.to_xml }
    end
  end
  
  # GET /audio/singles/new
  def new
    @single = Single.new
  end
  
  # POST /audio/singles
  # POST /audio/singles.:format
  def create
    @single = Single.new(params[:single])
    respond_to do |format|
      if @single.save
        flash[:notice] = 'Single registered successfully. It will be downloaded soon.'
        format.html { redirect_to audio_single_path(@single) }
        format.xml { head :ok }
      else
        flash[:error] = 'There were problems creating the single'
        format.html { render :action => 'new' }
        format.xml { render :xml => @single.errors.to_xml }
      end
    end
  end
  
  # GET /audio/singles/:id/edit/
  def edit
    @single = Single.find(params[:id])
    respond_to do |format|
      format.html # edit.html.erb
      format.xml { render :xml => @single.to_xml }
    end
  end
  
  # PUT /audio/singles/:id
  # PUT /audio/singles/:id.:format
  def update
    @single = Single.find(params[:id])
    respond_to do |format|
      if @single.update_attributes(params[:single])
        flash[:notice] = 'Single updated successfully'
        format.html { redirect_to single_path(@single_path) }
        format.xml { head :ok }
      else
        flash[:error] = 'There were problems updating the single'
        format.html { render :action => 'edit' }
        format.xml { render :xml => @single.errors.to_xml }
      end
    end
  end
  
  # DELETE /audio/singles/:id
  # DELETE /audio/singles/:id.:format
  def destroy
    @single = Single.find(params[:id])
    @single.destroy
    respond_to do |format|
      flash[:notice] = 'Single removed'
      format.html { redirect_to singles_path }
      format.xml { head :ok }
    end
  end
  
  # GET /audio/singles/unavailable.:format
  def unavailable
    @singles = Single.find_all_unavailable
    respond_to do |format|
      format.xml { render :xml => @singles.to_xml }
    end
  end
  
  protected
  
  def active_nav
    @active = 'audio_assets'
  end
end
