class CreateConflicts < ActiveRecord::Migration
  def self.up
    create_table :conflicts do |t|
      t.integer :active_broadcast_id
      t.datetime :dtstart, :dtend

      t.timestamps
    end

    create_table :conflicts_broadcasts, :id => false  do |t|
      t.integer :conflict_id
      t.integer :broadcast_id
    end
  end

  def self.down
    drop_table :conflicts
    drop_table :conflicts_new_broadcasts
  end
end
