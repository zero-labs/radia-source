class AddActiveFlagToBroadcast < ActiveRecord::Migration
  def self.up
    add_column :broadcasts, :active, :boolean
  end

  def self.down
    remove_column :broadcasts, :active
  end
end
