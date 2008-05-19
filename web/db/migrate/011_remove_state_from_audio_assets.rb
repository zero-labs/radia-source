class RemoveStateFromAudioAssets < ActiveRecord::Migration
  def self.up
    remove_column :audio_assets, :state
    add_column :audio_assets, :available, :boolean, :default => false
  end

  def self.down
    add_column :audio_assets, :state, :string
    remove_column :audio_assets, :available
  end
end
