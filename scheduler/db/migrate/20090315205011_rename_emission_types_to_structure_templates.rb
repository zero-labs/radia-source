class RenameEmissionTypesToStructureTemplates < ActiveRecord::Migration
  def self.up
    rename_table :emission_types, :structure_templates
  end

  def self.down
    rename_table :structure_templates, :emission_types
  end
end
