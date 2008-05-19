module ServiceInterface
  module Ftp
    require 'net/ftp'
    def get(uri, login, password)

    end

    def self.list(uri, login, password)
      location, folder = ServiceInterface.location_and_folder(uri)
      Net::FTP.open(location) do |ftp|
        ftp.login(login, password)
        ftp.chdir(folder) unless folder.blank?
        ftp.nlst
      end
    end
  end
  
  def self.location_and_folder(str)
    r = str.split(/\//)
    [ r.first, r.slice(1..-1).join('/') ]
  end
end