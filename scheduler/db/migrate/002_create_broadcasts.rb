class CreateBroadcasts < ActiveRecord::Migration
  def self.up
    drop_table :originals
    drop_table :repetitions
    
    create_table :broadcasts do |t|
      t.string :type # STI
      t.datetime :start, :end
      
      # for originals
      t.belongs_to :original_type, :program, :program_schedule
      t.text     :description
      
      # for repetitions
      t.belongs_to :original

      t.timestamps
    end
  end

  def self.down
    
    create_table :originals, :force => true do |t|
      t.belongs_to :original_type, :program, :program_schedule
      t.datetime :start, :end
      t.boolean  :active, :default => true
      t.boolean  :flag, :default => false
      t.text     :description
      t.timestamps
    end
    
    create_table :repetitions do |t|
      t.belongs_to :original
      t.datetime :start, :end
      t.timestamps
    end
    
    drop_table :broadcasts
  end
end
