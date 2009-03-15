class StructureObserver < ActiveRecord::Observer
  
  def after_save(structure)
    if structure.playable.kind_of?(StructureTemplate)
      structure.playable.emissions.find(:all, :conditions => ["dtstart >= ?", Time.now]).each do |e| 
        # is the e.modified? check really needed?
        e.update_structure unless e.modified? 
      end
    end
  end
end
