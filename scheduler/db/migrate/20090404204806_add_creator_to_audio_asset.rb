class AddCreatorToAudioAsset < ActiveRecord::Migration
  def self.up
    add_column :audio_assets, :creator_id, :integer
  end

  def self.down
    remove_column :audio_assets, :creator_id
  end
end
