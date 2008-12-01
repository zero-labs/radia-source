class RemoveFieldsFromAssets < ActiveRecord::Migration
  def self.up
    remove_column :audio_assets, :location
  end

  def self.down
    add_column :audio_assets, :location, :string
  end
end
