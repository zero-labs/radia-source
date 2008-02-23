class AddWebActiveVersion < ActiveRecord::Migration
  def self.up
    add_column :schedules, :web_active_version, :integer
  end

  def self.down
    remove_column :schedules, :web_active_version
  end
end
