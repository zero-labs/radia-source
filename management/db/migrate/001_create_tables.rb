class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :action_configurations, :force => true do |t|
      t.integer  :process_configuration_id
      t.string   :attrname, :activity, :string_value
      t.boolean  :perform
      t.float    :numerical_value
      t.timestamps
    end
    
    create_table :activity_configurations, :force => true do |t|
      t.integer  :process_configuration_id
      t.string   :type
      t.timestamps
    end
    
    create_table :authorships, :force => true do |t|
      t.integer  :program_id
      t.integer  :user_id
      t.boolean  :always, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday
      t.timestamps
    end
    
    create_table :blocs, :force => true do |t|
      t.belongs_to :playable
      t.string :playable_type
      t.timestamps
    end
    
    create_table :emission_types, :force => true do |t|
      t.string :name, :color, :calendar_url
      t.timestamps
    end
    
    create_table :emissions, :force => true do |t|
      t.belongs_to :emission_type, :program, :program_schedule
      t.datetime :start, :end
      t.boolean  :active, :default => true
      t.boolean  :flag, :default => false
      t.text     :description
      t.timestamps
    end
    
    create_table :open_id_authentication_associations, :force => true do |t|
      t.integer :issued, :lifetime
      t.string  :handle, :assoc_type
      t.binary  :server_url, :secret
    end
    
    create_table :open_id_authentication_nonces, :force => true do |t|
      t.integer :timestamp,  :null => false
      t.string  :server_url
      t.string  :salt,       :null => false
    end
    
    create_table :process_configurations, :force => true do |t|
      t.integer  :processable_id
      t.string   :type, :processable_type
      t.timestamps
    end
    
    create_table :program_schedules, :force => true do |t|
      t.timestamps
    end
    
    create_table :programs, :force => true do |t|
      t.string   :name
      t.boolean  :active,      :default => true
      t.text     :description
      t.timestamps
    end
    
    create_table :roles, :force => true do |t|
      t.string   :name,              :limit => 40
      t.string   :authorizable_type, :limit => 40
      t.integer  :authorizable_id
      t.timestamps
    end
    
    create_table :roles_users, :id => false, :force => true do |t|
      t.belongs_to :user, :role
      t.timestamps
    end
    
    create_table :service_configurations, :force => true do |t|
      t.integer  :process_configuration_id
      t.string   :attrname, :activity, :protocol, :location, :login, :password
      t.timestamps
    end
    
    create_table :urlnames, :force => true do |t|
      t.string  :name, :nameable_type
      t.integer :nameable_id
    end
    
    create_table :users, :force => true do |t|
      t.string   :name, :login, :email, :identity_url, :remember_token
      t.string   :crypted_password,          :limit => 40
      t.string   :salt,                      :limit => 40
      t.string   :activation_code,           :limit => 40
      t.datetime :remember_token_expires_at, :activated_at
      t.timestamps
    end
    
    create_table :repetitions do |t|
      t.belongs_to :emission
      t.datetime :start, :end
      t.timestamps
    end
    
    create_table :bloc_elements do |t|
      t.belongs_to :bloc, :audio_asset
      t.string :type
      t.integer :position, :length, :items_to_play
      t.boolean :random, :fill
      t.timestamps
    end
    
    create_table :playlist_elements do |t|
      t.belongs_to :playlist, :audio_asset
      t.integer :position
    end
    
    create_table :audio_assets do |t|
      t.boolean :authored, :default => false
      t.string :type, :location, :title
      t.timestamps
    end
  end

  def self.down
    drop_table :action_configurations
    drop_table :activity_configurations
    drop_table :authorships
    drop_table :blocs
    drop_table :emission_types
    drop_table :emissions
    drop_table :open_id_authentication_associations
    drop_table :open_id_authentication_nonces
    drop_table :process_configurations
    drop_table :program_schedules
    drop_table :programs
    drop_table :roles
    drop_table :roles_users
    drop_table :service_configurations
    drop_table :urlnames
    drop_table :users
    drop_table :repetitions
    drop_table :bloc_elements
    drop_table :playlist_elements
    drop_table :audio_assets
    
  end
end
