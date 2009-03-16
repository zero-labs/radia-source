require 'uri'

module AssetDownloader
  
  # 
  def self.check_and_download
    puts "DEBUG";0
    unavailable = ManagementResources::Single.find_unavailable + ManagementResources::Spot.find_unavailable
    unavailable.each do |u|
      next unless u.start_download
      
      Thread.new do
        begin 
          download(u.retrieval_uri)
        ensure
          u.end_download
        end
      end
    end
  end
  
  protected

  # Uses URI.split to split the retrieval uri string 
  # into an Array with the following positions: 
  # * 0 Scheme
  # * 1 Userinfo
  # * 2 Host
  # * 3 Port
  # * 4 Registry
  # * 5 Path
  # * 6 Opaque
  # * 7 Query
  # * 8 Fragment
  # 
  # Based on this, the correct service handler is used and the
  # file is downloaded
  def self.download(uri)
    uri_array = URI.split(uri)    
    userinfo = \
    if uri_array[1].nil? 
      find_userinfo("#{uri_array[0]}://#{uri_array[2]}") 
    else 
      uri_array[1]
    end

    case uri_array[0]
    when 'ftp'  
      puts uri_array[2], uri_array[5], userinfo;0
      ServiceInterface::Ftp.get(uri_array[2], uri_array[5], userinfo)
    when 'http'
    end
  end
  
  # Searches the configuration hash for a user:password
  # for a given URI.
  # If one is not found, it returns the default "anonymous:"
  def self.find_userinfo(uri)
    $playout_config['services'].each do |s|
      next if s['uri'] != uri
      return "#{s['user']}:#{s['password']}"
    end
    "anonymous:" # service
  end
end
