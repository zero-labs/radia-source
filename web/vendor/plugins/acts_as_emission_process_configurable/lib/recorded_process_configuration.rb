class RecordedProcessConfiguration < ProcessConfiguration
  # Delivery
  has_one :delivery_service, :class_name => "ServiceConfiguration", 
          :foreign_key => "process_configuration_id", :conditions => "attrname = 'delivery_service'"
  has_one :delivery_deadline, :class_name => "ActionConfiguration", 
          :foreign_key => "process_configuration_id", :conditions => "attrname = 'delivery_deadline'"
  
  # Validation
  has_one :validation_time_stretch, :class_name => "ActionConfiguration", 
          :foreign_key => "process_configuration_id", :conditions => "attrname = 'validation_time_stretch'"
  has_one :validation_normalize, :class_name => "ActionConfiguration", 
          :foreign_key => "process_configuration_id", :conditions => "attrname = 'validation_normalize'"
  has_one :validation_fade_out, :class_name => "ActionConfiguration",
          :foreign_key => "process_configuration_id", :conditions => "attrname = 'validation_fade_out'"
  has_one :validation_playlist, :class_name => "ActionConfiguration", 
          :foreign_key => "process_configuration_id", :conditions => "attrname = 'validation_playlist'"
          
  # Broadcast
  
  
  # Post-Broadcast
  has_one :post_broadcast_archive, :class_name => 'ServiceConfiguration', :foreign_key => 'process_configuration_id',
          :conditions => "attrname = 'post_broadcast_archive'"
  
  def name
    "Recorded"
  end
  
  def activities
    { :delivery => delivery_fields, :validation => validation_fields, :post_broadcast => post_broadcast_fields }
  end
  
  def init_fields
    init_delivery
    init_validation
    init_broadcast
    init_post_broadcast
  end
  
  def delivery_service_field=(hsh) 
    self.delivery_service.update_attributes(hsh)
  end
  
  def delivery_deadline_field=(hsh)
    hsh[:string_value] = hsh[:string_value].join(' ')
    self.delivery_deadline.update_attributes(hsh)
  end
  
  def validation_time_stretch_field=(hsh)
    self.validation_time_stretch.update_attributes(hsh)
  end
  
  def validation_normalize_field=(hsh)
    self.validation_normalize.update_attributes(hsh)
  end
  
  def validation_fade_out_field=(hsh)
    self.validation_fade_out.update_attributes(hsh)
  end
  
  def validation_playlist_field=(hsh)
    self.validation_playlist.update_attributes(hsh)
  end
  
  def post_broadcast_archive_field=(hsh)
    self.post_broadcast_archive.update_attributes(hsh)
  end
  
  protected
  
  def init_delivery
    self.delivery_service = ServiceConfiguration.create(:process_configuration => self, :activity => 'Delivery', 
                                                        :protocol => 'ftp', :location => 'localhost', :attrname => 'delivery_service')
    self.delivery_deadline = ActionConfiguration.create(:process_configuration => self, :activity => 'Delivery', :perform => true,
                                                        :string_value => "3 hours before", :attrname => 'delivery_deadline')
  end
  
  def init_validation
    self.validation_time_stretch = ActionConfiguration.create(:process_configuration => self, :activity => 'Validation', :perform => true, 
                                                              :numerical_value => 98, :attrname => 'validation_time_stretch')
    self.validation_normalize = ActionConfiguration.create(:process_configuration => self, :activity => 'Validation', :perform => true, 
                                                           :numerical_value => 98, :attrname => 'validation_normalize')
    self.validation_fade_out = ActionConfiguration.create(:process_configuration => self, :activity => 'Validation', :perform => true, 
                                                          :numerical_value => 10, :attrname => 'validation_fade_out')
    self.validation_playlist = ActionConfiguration.create(:process_configuration => self, :activity => 'Validation', :perform => true, 
                                                          :string_value => "/home/playlists/1.pls", :attrname => 'validation_playlist')                                                       
  end
  
  def init_broadcast
    
  end
  
  def init_post_broadcast
    self.post_broadcast_archive = ServiceConfiguration.create(:process_configuration => self, :activity => 'Post-Broadcast', 
                                  :protocol => 'ftp', :location => 'localhost', :attrname => 'post_broadcast_archive')
  end
  
  def delivery_fields
    { :deadline => [:action, "Deadline", "Activate delivery deadline", :string_value, "When?", 
                    [['minutes', 'hours', 'days'], ['before', 'after']]],
      :service => [:service, "Where should emissions be retrieved?"]}
  end
  
  def validation_fields
    { :time_stretch => [:action, "Sound Time-Stretch", "Time-stretch emission", :numerical_value, "Percentage"], 
      :normalize => [:action, "Sound normalization", "Normalize emission", :numerical_value, "Level"],
      :fade_out => [:action, "Sound Fade-out", "Fade-out if emission is over specified duration", :numerical_value, "Number of seconds"],
      :playlist => [:action, "Alternative playlist", "Use playlist if emission is under specified duration", :numerical_value, "Playlist"]}
  end
  
  def broadcast_fields
    
  end
  
  def post_broadcast_fields
    { :archive => [:service, "Archive location"] }
  end
end
