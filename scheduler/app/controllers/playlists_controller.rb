class PlaylistsController < ApplicationController
  before_filter :load_playlist, :only => [:show, :edit, :update, :destroy]
  before_filter :new_playlist, :only => :new
  before_filter :new_playlist_from_params, :only => :create
  
  filter_access_to :all, :attribute_check => true
  filter_access_to :index, :attribute_check => false
  
  # GET /audio/playlists
  # GET /audio/playlists.:format
  def index
    @playlists = Playlist.find(:all)
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @playlists.to_xml }
    end
  end
  
  # GET /audio/playlists/new
  def new
    respond_to do |format|
      format.html # new.html.erb
    end
  end
  
  # POST /audio/playlist
  # POST /audio/playlist.:format
  def create
    respond_to do |format|
      if @playlist.save
        flash[:notice] = "Playlist created successfully"
        format.html { redirect_to :action => 'index' }
        format.xml { head :ok }
      else
        flash[:error] = "There were problems creating the playlist"
        format.html { render :action => 'new' }
        format.xml { render :xml => @playlist.errors.to_xml }
      end
    end
  end
  
  # GET /audio/playlists/:id
  # GET /audio/playlists/:id.:format
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @playlist.to_xml }
    end
  end
  
  # GET /audio/playlists/:id/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end
  
  # PUT /audio/playlists/:id
  # PUT /audio/playlists/:id.:format
  def update
    respond_to do |format|
      if @playlist.update_attributes(params[:playlist])
        flash[:notice] = 'Playlist updated successfully'
        format.html { redirect_to single_path(@single_path) }
        format.xml { head :ok }
      else
        flash[:error] = 'There were problems updating the playlist'
        format.html { render :action => 'edit' }
        format.xml { render :xml => @single.errors.to_xml }
      end
    end
  end
  
  protected
  
  def active_nav
    @active = 'audio_assets'
  end
  
  def load_playlist
    @playlist = Playlist.find(params[:id])
  end
  
  def new_playlist
    @playlist = Playlist.new
    @available_singles = Single.find(:all, :conditions => 'delivered_at is not null')
  end
  
  def new_playlist_from_params
    @playlist = Playlist.new(params[:playlist])
  end
  
end
