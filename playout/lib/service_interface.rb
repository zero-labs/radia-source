module ServiceInterface
  module Ftp
    require 'net/ftp'

    # Downloads the file at the given FTP host and from_path
    # The download is made to to_path
    # Returns the name of the local file where the download was made
    def self.get(host, from_path, userinfo = 'anonymous:')
      user, password = ServiceInterface.split_userinfo(userinfo)
      Net::FTP.open(host) do |ftp|
        ftp.login(user, password)
        ftp.getbinaryfile(from_path) # TODO to_path
      end
      File.basename(from_path)
    end
  end

  protected

  # Splits a UserInfo string (e.g.: 'user:password')
  # into a two-element array ['user', 'password']
  # If an element is not matched, it's array position will be nil
  def self.split_userinfo(userinfo)
    user, passwd = userinfo.split(/\:/)
    [user, passwd]
  end
end