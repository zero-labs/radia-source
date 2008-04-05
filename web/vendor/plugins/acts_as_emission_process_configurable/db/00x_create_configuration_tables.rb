class CreateConfigurationTables < ActiveRecord::Migration
  def self.up
    create_table :service_configurations do |t|
      t.string :activity
      t.string :protocol, :location, :login, :password
      t.timestamps
    end
    
    create_table :action_configurations do |t|
      t.string :activity
      t.boolean :perform
      t.float :numerical_value
      t.string :string_value
      t.timestamps
    end
    
    create_table :process_configurations do |t|
      t.string :type, :processable_type
      t.timestamps
    end
  end

  def self.down
    drop_table :service_configurations
    drop_table :action_configurations
    drop_table :process_configurations
  end
end
