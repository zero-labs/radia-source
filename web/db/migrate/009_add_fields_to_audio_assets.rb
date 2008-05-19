class AddFieldsToAudioAssets < ActiveRecord::Migration
  def self.up
    add_column :audio_assets, :live_source_id, :integer
    add_column :audio_assets, :state, :string
    remove_column :audio_assets, :delivered
  end

  def self.down
    add_column :audio_assets, :delivered, :boolean, :default => false
    remove_column :audio_assets, :live_source_id
    remove_column :audio_assets, :state
  end
end
