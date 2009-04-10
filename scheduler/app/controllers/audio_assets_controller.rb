class AudioAssetsController < ApplicationController
  before_filter :load_audio_assets, :only => :show
  
  filter_access_to :show, :attribute_check => false
  
  # GET /audio
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @audio.to_xml }
    end
  end
  
  protected
  
  def load_audio_assets
     @playlists = Playlist.find(:all)
     @singles = Single.find(:all)
     @spots = Spot.find(:all)
     @audio = { :playlists => @playlists, :singles => @singles, :spots => @spots }
  end
  
  def active_nav
    @active = 'audio_assets'
  end
end
