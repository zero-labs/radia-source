module ProcessConfigurationHelper
  def service_config(process, field, title)
    render :partial => 'service', 
          :locals => { :process => process, :field => field, :title => title}
  end
  
  def action_config(process, field, title, attribute)
    raise RuntimeError if attribute.size < 3
    render :partial => 'action', 
          :locals => { :process => process, :field => field, :title => title, :attribute => attribute }
  end
  
  def service_show(process, field, title)
    render :partial => 'service_show', 
           :locals => { :process => process, :field => field, :title => title }
  end
  
  def action_show(process, field, title, attribute)
    render :partial => 'action_show', 
          :locals => { :process => process, :field => field, :title => title, :attribute => attribute}
  end
  
end
