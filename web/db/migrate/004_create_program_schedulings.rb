class CreateProgramSchedulings < ActiveRecord::Migration
  def self.up
    create_table :program_schedulings do |t|
      t.belongs_to :schedule_version
      t.belongs_to :program
      t.datetime :start
      t.datetime :end
      t.string :uid
      t.timestamps
    end
  end

  def self.down
    drop_table :program_schedulings
  end
end
