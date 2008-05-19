class RemoveProcessableTables < ActiveRecord::Migration
  def self.up
    drop_table :action_configurations
    drop_table :activity_configurations
    drop_table :service_configurations
  end

  def self.down
    create_table "service_configurations", :force => true do |t|
      t.integer  "process_configuration_id"
      t.string   "attrname"
      t.string   "activity"
      t.string   "protocol"
      t.string   "location"
      t.string   "login"
      t.string   "password"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    create_table "action_configurations", :force => true do |t|
      t.integer  "process_configuration_id"
      t.string   "attrname"
      t.string   "activity"
      t.string   "string_value"
      t.boolean  "perform"
      t.float    "numerical_value"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "activity_configurations", :force => true do |t|
      t.integer  "process_configuration_id"
      t.string   "type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
  end
end
