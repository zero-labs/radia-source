class CreateScheduleVersions < ActiveRecord::Migration
  def self.up
    create_table :schedule_versions do |t|
      t.belongs_to :schedule
      t.string :uri
      t.timestamps
    end
  end

  def self.down
    drop_table :schedule_versions
  end
end
