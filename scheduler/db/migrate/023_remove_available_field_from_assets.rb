class RemoveAvailableFieldFromAssets < ActiveRecord::Migration
  def self.up
    remove_column :audio_assets, :available
  end

  def self.down
    add_column :audio_assets, :available, :boolean, :default => false
  end
end
