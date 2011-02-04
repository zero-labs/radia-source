class MergeAllMigrations < ActiveRecord::Migration
  def self.up
    
    create_table :authorships, :force => true do |t|
      t.integer  :program_id
      t.integer  :user_id
      t.boolean  :always, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday
      t.timestamps
    end
    
    create_table :structures, :force => true do |t|
      t.belongs_to :playable
      t.string :playable_type
      t.timestamps
    end
    
    create_table :structure_templates, :force => true do |t|
      t.string :name, :color, :calendar_url
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
      t.integer :user_id, :null => false, :default => 1
      t.timestamps
    end
    
    create_table :roles_users, :id => false, :force => true do |t|
      t.belongs_to :user, :role
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
    
    create_table :segments do |t|
      t.belongs_to :structure, :audio_asset
      t.string :type
      t.integer :position, :length, :items_to_play
      t.boolean :random, :fill
      t.timestamps
    end
    
    create_table :playlist_elements do |t|
      t.belongs_to :playlist, :audio_asset
      t.integer :position
    end

    create_table :asset_services do |t|
      t.belongs_to :settings, :default => 1
      t.string :name, :protocol, :uri, :login
      t.boolean :default, :default => false
      t.timestamps
    end
    
    create_table :audio_assets do |t|
      t.boolean :authored, :default => false
      t.string :type, :title
      t.float :length
      t.string :md5_hash
      t.string :deadline
      t.integer :live_source_id
      t.string :retrieval_uri
      t.datetime :delivered_at
      t.integer :creator_id
      t.timestamps
    end

    create_table :broadcasts do |t|
      t.string :type # STI
      t.datetime :dtstart, :dtend
      
      # for originals
      t.belongs_to :structure_template, :program, :program_schedule
      t.text     :description
      
      # for repetitions
      t.belongs_to :original
      t.boolean :active, :default => false

      t.belongs_to :conflict
      t.timestamps
    end

    create_table :settings do |t|
      t.string :station_name
      t.string :repetitions_url
      t.timestamps
    end

    create_table :live_sources do |t|
      t.belongs_to :settings, :default => 1
      t.string :uri, :name
    end

    create_table :conversations do |t|
      t.column :subject, :string, :default => ""
      t.column :created_at, :datetime, :null => false
    end

    create_table :messages do |t|
      t.column :body, :text
      t.column :subject, :string, :default => ""
      t.column :headers, :text
      t.column :sender_id, :integer, :null => false
      t.column :conversation_id, :integer
      t.column :sent, :boolean, :default => false
      t.column :created_at, :datetime, :null => false
    end
    #i use foreign keys but its a custom method, so i'm leaving it up to you if you want them.

    create_table :messages_recipients, :id => false do |t|
      t.column :message_id, :integer, :null => false
      t.column :recipient_id, :integer, :null => false
    end

    create_table :mail do |t|
      t.column :user_id, :integer, :null => false
      t.column :message_id, :integer, :null => false
      t.column :conversation_id, :integer
      t.column :read, :boolean, :default => false
      t.column :trashed, :boolean, :default => false
      t.column :mailbox, :string, :limit => 25
      t.column :created_at, :datetime, :null => false
    end

    create_table :delayed_jobs, :force => true do |t|
      t.integer  :priority, :default => 0      # Allows some jobs to jump to the front of the queue
      t.integer  :attempts, :default => 0      # Provides for retries, but still fail eventually.
      t.text     :handler                      # YAML-encoded string of the object that will do work
      t.string   :last_error                   # reason for last failure (See Note below)
      t.datetime :run_at                       # When to run. Could be Time.now for immediately, or sometime in the future.
      t.datetime :locked_at                    # Set when a client is working on this object
      t.datetime :failed_at                    # Set when all retries have failed (actually, by default, the record is deleted instead)
      t.string   :locked_by                    # Who is working on this object (if locked)

      t.timestamps
    end

    add_index :delayed_jobs, :locked_by

    create_table :conflicts do |t|
      t.datetime :dtstart, :dtend

      t.timestamps
    end
  end

  def self.down
    drop_table :authorships
    drop_table :structures
    drop_table :structure_templates
    drop_table :open_id_authentication_associations
    drop_table :open_id_authentication_nonces
    drop_table :process_configurations
    drop_table :program_schedules
    drop_table :programs
    drop_table :roles
    drop_table :roles_users
    drop_table :urlnames
    drop_table :users
    drop_table :segments
    drop_table :playlist_elements
    drop_table :asset_services
    drop_table :audio_assets
    drop_table :broadcasts
    drop_table :settings
    drop_table :live_sources
    drop_table :conversations
    drop_table :messages
    drop_table :messages_recipients
    drop_table :mail
    drop_table :delayed_jobs
    drop_table :conflicts
  end
end
