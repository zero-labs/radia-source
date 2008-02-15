class AddNameToProgram < ActiveRecord::Migration
  def self.up
    add_column :programs, :name, :string
  end

  def self.down
    remove_column :programs, :name
  end
end
