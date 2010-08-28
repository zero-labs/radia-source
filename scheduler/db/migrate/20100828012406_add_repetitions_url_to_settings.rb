class AddRepetitionsUrlToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :repetitions_url, :string
  end

  def self.down
    remove_column :settings, :repetitions_url
  end
end
