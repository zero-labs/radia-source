class RenameLiveSourceTitleToName < ActiveRecord::Migration
  def self.up
    rename_column :live_sources, :title, :name
  end

  def self.down
    rename_column :live_sources, :name, :title
  end
end
