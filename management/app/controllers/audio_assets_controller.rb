class AudioAssetsController < ApplicationController
  before_filter :login_required, :except => [:index]
  
  # GET /audio
  def show
    @playlists = Playlist.find(:all)
    @singles = Single.find(:all)
    @spots = Spot.find(:all)
    @audio = { :playlists => @playlists, :singles => @singles, :spots => @spots }
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @audio.to_xml }
    end
  end
  
  protected
  
  def active_nav
    @active = 'audio_assets'
  end
end
