class AssetService < ActiveRecord::Base
  include RadiaSource::ServiceInterface
  
  PROTOCOLS = %w(ftp)
  
  belongs_to :settings
  
  validates_presence_of :protocol, :uri, :login
  validates_inclusion_of :protocol, :in => PROTOCOLS
    
  ## Class methods
  
  # Returns an Array of Strings, with the names of the accepted protocols
  def self.accepted_protocols
    PROTOCOLS
  end
  
  ### Instance methods
  def settings_id=(value)
    self.settings = Settings.find(value)
  end
  
  def list(password)
    case self.protocol
    when 'ftp'
      Ftp::list(self.uri, self.login, password)
    end
  end
  
  def full_uri
    "#{self.protocol}://#{self.uri}"
  end
end
