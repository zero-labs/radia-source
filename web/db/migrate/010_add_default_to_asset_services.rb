class AddDefaultToAssetServices < ActiveRecord::Migration
  def self.up
    add_column :asset_services, :default, :boolean, :default => false
  end

  def self.down
    remove_column :asset_services, :default
  end
end
