class UpdateAudioAssets < ActiveRecord::Migration
  def self.up
    add_column :audio_assets, :asset_service_id, :integer
    add_column :audio_assets, :duration, :float
    add_column :audio_assets, :delivered, :boolean, :default => false
    add_column :audio_assets, :md5_hash, :string
  end

  def self.down
    remove_column :audio_assets, :asset_service_id
    remove_column :audio_assets, :duration
    remove_column :audio_assets, :delivered
    remove_column :audio_assets, :md5_hash
  end
end
