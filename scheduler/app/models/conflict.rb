class Conflict < ActiveRecord::Base
  include ActiveRecordEnumerable

  has_and_belongs_to_many  :new_broadcasts, :class_name =>"Broadcast", :join_table => "conflicts_new_broadcasts", :association_foreign_key => "new_broadcast_id"
  belongs_to :active_broadcast, :class_name => "Broadcast", :foreign_key => "active_broadcast_id"

  enumerate :action, :as => RadiaSource::ProgramSchedule::Migrate.Actions, :default => RadiaSource::ProgramSchedule::Migrate.DefaultAction

  def find_or_create_conflict_by_old_broadcast(bc)
    conflict = find(:first, :conditions => {:old_broadcast_id => bc.id})

    if conflict.nil?
      conflict = Conflict.create
      bc.conflicting_old_broadcast = conflict
      bc.save
    end

    return conflict
  end

  def self.find_in_range(startdt, enddt, old=false)
    if old
      b_ids = Conflict.all(:select => "old_broadcast_id")

      return [] if b_ids.empty?
      broadcasts = Broadcast.find(:all, :select => "id", :conditions =>
                            ["(dtstart < :t1 AND dtend > :t1) OR (dtstart >= :t1 AND dtstart < :t2) AND old_broadcast_id IN :ids",
                            {:t1 => startdt, :t2 => enddt, :ids => b_ids}])
      return Conflict.all(:conditions => { :old_broadcast_id => broadcasts })
      

    else
      broadcasts =  Broadcast.find(:all, :select => "id", :conditions => 
                            ["(dtstart < :t1 AND dtend > :t1) OR (dtstart >= :t1 AND dtstart < :t2)",
                            {:t1 => startdt, :t2 => enddt}])
      return Conflict.all(:conditions => { :old_broadcast_id => broadcasts })
    end

    #return find(:all, :conditions => ["(dtstart < ? AND dtend > ?) OR (dtstart >= ? AND dtend <= ?) OR (dtstart < ? AND dtend > ?)", 
    #                            startdt, startdt, startdt, enddt, enddt, startdt], :order => "dtstart ASC")
  end

  def has_dirty_broadcast?
    return false if self.conflicting_old_broadcast.nil?
    return self.conflicting_old_broadcast.dirty?
  end


end
