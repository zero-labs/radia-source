class AddDeliveryDateToAudioAsset < ActiveRecord::Migration
  def self.up
    add_column :audio_assets, :delivered_at, :datetime
  end

  def self.down
    remove_column :audio_assets, :delivered_at
  end
end
