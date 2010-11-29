class CreateConflicts < ActiveRecord::Migration
  def self.up
    create_table :conflicts do |t|
      t.integer :active_broadcast_id
      t.string  :action

      t.timestamps
    end

    create_table :conflicts_new_broadcasts, :id => false  do |t|
      t.integer :conflict_id
      t.integer :new_broadcast_id
    end
  end

  def self.down
    drop_table :conflicts
    drop_table :conflicts_new_broadcasts
  end
end
