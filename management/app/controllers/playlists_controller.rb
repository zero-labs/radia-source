class PlaylistsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  
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
    @playlist = Playlist.new
  end
  
  # POST /audio/playlist
  # POST /audio/playlist.:format
  def create
    @playlist = Playlist.new(params[:playlist])
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
  
  # GET /audio/playlists
  def edit
    @playlist = Playlist.find(params[:id])
  end
  
  # PUT /audio/playlists/:id
  # PUT /audio/playlists/:id.:format
  def update
    @playlist
  end
  
  protected
  
  def active_nav
    @active = 'audio_assets'
  end
end
