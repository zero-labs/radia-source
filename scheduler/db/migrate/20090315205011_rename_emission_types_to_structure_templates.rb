class RenameEmissionTypesToStructureTemplates < ActiveRecord::Migration
  def self.up
    rename_column :broadcasts, :emission_type_id, :structure_template_id
    rename_table :emission_types, :structure_templates
  end

  def self.down
    rename_column :broadcasts, :structure_template_id, :emission_type_id
    rename_table :structure_templates, :emission_types
  end
end
