class AddArchivalDataToAudioAsset < ActiveRecord::Migration
  def self.up
    add_column :audio_assets, :archived_at, :datetime
    add_column :audio_assets, :archival_uri, :string
  end

  def self.down
    remove_column :audio_assets, :archival_uri
    remove_column :audio_assets, :archived_at
  end
end
