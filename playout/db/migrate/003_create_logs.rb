class CreateLogs < ActiveRecord::Migration
  def self.up
    create_table :logs do |t|
      t.belongs_to :audio_asset
      t.datetime :played_at
    end
  end

  def self.down
    drop_table :logs
  end
end
