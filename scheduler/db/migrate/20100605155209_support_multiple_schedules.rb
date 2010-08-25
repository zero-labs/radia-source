class SupportMultipleSchedules < ActiveRecord::Migration
  def self.up
    add_column :program_schedules, :active, :boolean, :default => false
  end

  def self.down
    remove_column :program_schedules, :active
  end
end
