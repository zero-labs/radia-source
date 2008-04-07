module ProcessConfigurationHelper
  def service_config(process, field, title)
    logger.debug "--> #{process}, #{field}, #{title}"
    render :partial => 'service', 
          :locals => { :process => process, :field => field, :title => title}
  end
  
  def action_config(process, field, title, attribute)
    raise RuntimeError if attribute.size < 3
    logger.debug "--> #{process}, #{field}, #{title}, #{attribute}"
    render :partial => 'action', 
          :locals => { :process => process, :field => field, :title => title, :attribute => attribute }
  end
  
end
