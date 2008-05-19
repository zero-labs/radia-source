module AssetDownloader
  def self.check_and_download
    unavailable = Single.find_unavailable
    unavailable.each do |u|
      Thread.new do
        u.fetch
      end
    end
  end
end
