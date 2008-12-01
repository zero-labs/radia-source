class ChangeDurationToLength < ActiveRecord::Migration
  def self.up
    rename_column :audio_assets, :duration, :length
  end

  def self.down
    rename_column :audio_assets, :length, :duration
  end
end
