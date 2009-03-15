class RenameBlocsToStructures < ActiveRecord::Migration
  def self.up
    rename_column :segments, :bloc_id, :structure_id
    rename_table :blocs, :structures
  end

  def self.down
    rename_column :segments, :structure_id, :bloc_id
    rename_table :structures, :blocs
  end
end
