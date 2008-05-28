class AudioAssetUri < ActiveRecord::Migration
  def self.up
    remove_column :audio_assets, :asset_service_id
    add_column :audio_assets, :retrieval_uri, :string
  end

  def self.down
    add_column :audio_assets, :asset_service_id, :integer
    remove_column :audio_assets, :retrieval_uri
  end
end
