class AddLevelToOperationLog < ActiveRecord::Migration
  def self.up
    add_column :operation_logs, :level, :string
    add_column :operation_logs, :message, :string
  end

  def self.down
    remove_column :operation_logs, :message
    remove_column :operation_logs, :level
  end
end
