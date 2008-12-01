module PlaylistsHelper
  def available_singles
    Single.find(:all, :conditions => ['available = ?', true])
  end
end
