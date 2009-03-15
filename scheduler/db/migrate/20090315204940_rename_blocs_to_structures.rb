class RenameBlocsToStructures < ActiveRecord::Migration
  def self.up
    rename_table :blocs, :structures
  end

  def self.down
    rename_table :structures, :blocs
  end
end
