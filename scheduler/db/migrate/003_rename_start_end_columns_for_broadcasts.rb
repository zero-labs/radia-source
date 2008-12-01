class RenameStartEndColumnsForBroadcasts < ActiveRecord::Migration
  def self.up
    rename_column :broadcasts, :start, :dtstart
    rename_column :broadcasts, :end, :dtend
  end

  def self.down
    rename_column :broadcasts, :dtstart, :start
    rename_column :broadcasts, :dtend, :end
  end
end
