class RenameOriginalTypesToStructureTemplates < ActiveRecord::Migration
  def self.up
    rename_column :broadcasts, :original_type_id, :structure_template_id
    rename_table :original_types, :structure_templates
  end

  def self.down
    rename_column :broadcasts, :structure_template_id, :original_type_id
    rename_table :structure_templates, :original_types
  end
end
