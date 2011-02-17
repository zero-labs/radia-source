class CreateOperationLogs < ActiveRecord::Migration
  def self.up
    create_table :operation_logs do |t|
      t.string :status
      t.string :type # holds single table inheritance info
      t.datetime :dtstart
      t.datetime :dtend
      t.text :operation_errors

      t.timestamps
    end
  end

  def self.down
    drop_table :operation_logs
  end
end
