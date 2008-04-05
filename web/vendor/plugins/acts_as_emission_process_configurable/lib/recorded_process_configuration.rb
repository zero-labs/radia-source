class RecordedProcessConfiguration < ActiveRecord::Base
  
  def activities
    {:delivery   => { "Service" => ServiceConfiguration, 
                      "Deadline" => ActionConfiguration }, 
     :validation => { "Time-stretch?" => ActionConfiguration, 
                      "Normalize?" => ActionConfiguration, 
                      "Fade-out?" => ActionConfiguration,
                      "Playlist?" => ActionConfiguration },
     :broadcast => { "Log listeners?" => ActionConfiguration}, 
     :post_broadcast}
  end
  
  def delivery=(service, deadline)
    
  end
  
  def validation=()
    
  end
  
  def broadcast=()
    
  end
  
  def post_broadcast=()
    
  end
end
