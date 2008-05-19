class CreateAssetServices < ActiveRecord::Migration
  def self.up
    create_table :asset_services do |t|
      t.belongs_to :settings, :default => 1
      t.string :name, :protocol, :uri, :login
      t.timestamps
    end
  end

  def self.down
    drop_table :asset_services
  end
end
