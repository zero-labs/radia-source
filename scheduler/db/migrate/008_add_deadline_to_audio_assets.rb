class AddDeadlineToAudioAssets < ActiveRecord::Migration
  def self.up
    add_column :audio_assets, :deadline, :string
  end

  def self.down
    remove_column :audio_assets, :deadline
  end
end
