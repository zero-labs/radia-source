class BlocObserver < ActiveRecord::Observer
  
  def after_save(bloc)
    if bloc.playable.kind_of?(EmissionType)
      bloc.playable.emissions.find(:all, :conditions => ["dtstart >= ?", Time.now]).each do |e| 
        # is the e.modified? check really needed?
        e.update_bloc unless e.modified? 
      end
    end
  end
end
