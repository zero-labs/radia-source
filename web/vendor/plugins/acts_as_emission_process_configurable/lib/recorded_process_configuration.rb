class RecordedProcessConfiguration < ProcessConfiguration
  # Delivery
  has_one :delivery_service, :class_name => "ServiceConfiguration", 
          :foreign_key => "process_configuration_id", :conditions => "attrname = 'delivery_service'"
  has_one :delivery_deadline, :class_name => "ActionConfiguration", 
          :foreign_key => "process_configuration_id", :conditions => "attrname = 'delivery_deadline'"
  
  # Validation
  has_one :validation_time_stretch, :class_name => "ActionConfiguration", 
          :foreign_key => "process_configuration_id", :conditions => "attrname = 'validation_time_stretch'"
  #has_one :validation_normalize, :class_name => "ActionConfiguration", :foreign_key => "process_configuration_id"
  #has_one :validation_fade_out, :class_name => "ActionConfiguration", :foreign_key => "process_configuration_id"
  #has_one :validation_playlist, :class_name => "ActionConfiguration", :foreign_key => "process_configuration_id"
  
  def name
    "Recorded"
  end
  
  def activities
    { :delivery => delivery_fields, :validation => validation_fields }
  end
  
  def init_fields
    init_delivery
    init_validation
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
  
  protected
  
  def delivery_fields
    { :service => [:service, "Where should emissions be retrieved?"], 
      :deadline => [:action, "Deadline", "Activate delivery deadline?", :string_value, "When?", 
                    [['minutes', 'hours', 'days'], ['before', 'after']]]}
  end
  
  def init_delivery
    self.delivery_service = ServiceConfiguration.create(:process_configuration => self,
                                                        :activity => 'Delivery', 
                                                        :protocol => 'ftp', 
                                                        :location => 'localhost',
                                                        :attrname => 'delivery_service')
    self.delivery_deadline = ActionConfiguration.create(:process_configuration => self,
                                                        :activity => 'Delivery',
                                                        :perform => true,
                                                        :string_value => "3 hours before", 
                                                        :attrname => 'delivery_deadline')
  end
  
  def init_validation
    self.validation_time_stretch = ActionConfiguration.create(:process_configuration => self,
                                                              :activity => 'Validation',
                                                              :perform => true,
                                                              :numerical_value => 4,
                                                              :attrname => 'validation_time_stretch')
  end
  
  def validation_fields
    {:time_stretch => [:action, "Time-Stretch", "Time-stretch program?", :numerical_value, "Percentage"]}
  end
end
