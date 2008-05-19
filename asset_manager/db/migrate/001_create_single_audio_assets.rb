class CreateSingleAudioAssets < ActiveRecord::Migration
  def self.up
    create_table :single_audio_assets do |t|
      t.integer :id_at_source
      t.string :location, :hash_code, :archive_uri, :status
      t.float :length
      t.timestamps
    end
  end

  def self.down
    drop_table :single_audio_assets
  end
end
