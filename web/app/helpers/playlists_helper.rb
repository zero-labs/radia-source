module PlaylistsHelper
  def available_singles
    SingleAudioAsset.find(:all, :conditions => ['available = ?', true])
  end
end
