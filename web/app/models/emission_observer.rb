class EmissionObserver < ActiveRecord::Observer
  def after_create(emission)
    #update_permissions(emission)
  end
  
  def after_save(emission)
    #update_permissions(emission)
  end
  
  def before_destroy(emission)
    #remove_permissions(emission)
  end
  
  private
  
  def update_permissions(emission)
    change_permissions(emission) { |a| a.update_permissions }
  end
  
  def remove_permissions(emission)
    change_permissions(emission) { |a| a.remove_permissions }
  end
  
  def change_permissions(emission)
    return if emission.program.nil? or emission.program.authorships.empty?
    emission.program.authorships.each do |a|
      yield a
    end
  end
end
