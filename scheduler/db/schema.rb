# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100908223952) do

  create_table "asset_services", :force => true do |t|
    t.integer  "settings_id", :default => 1
    t.string   "name"
    t.string   "protocol"
    t.string   "uri"
    t.string   "login"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "default",     :default => false
  end

  create_table "audio_assets", :force => true do |t|
    t.boolean  "authored",       :default => false
    t.string   "type"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "length"
    t.string   "md5_hash"
    t.string   "deadline"
    t.integer  "live_source_id"
    t.string   "retrieval_uri"
    t.datetime "delivered_at"
    t.integer  "creator_id"
  end

  create_table "authorships", :force => true do |t|
    t.integer  "program_id"
    t.integer  "user_id"
    t.boolean  "always"
    t.boolean  "monday"
    t.boolean  "tuesday"
    t.boolean  "wednesday"
    t.boolean  "thursday"
    t.boolean  "friday"
    t.boolean  "saturday"
    t.boolean  "sunday"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "broadcasts", :force => true do |t|
    t.string   "type"
    t.datetime "dtstart"
    t.datetime "dtend"
    t.integer  "structure_template_id"
    t.integer  "program_id"
    t.integer  "program_schedule_id"
    t.text     "description"
    t.integer  "original_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                :default => false
  end

  create_table "conflicts", :force => true do |t|
    t.integer  "active_broadcast_id"
    t.datetime "dtstart"
    t.datetime "dtend"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conflicts_broadcasts", :id => false, :force => true do |t|
    t.integer "conflict_id"
    t.integer "broadcast_id"
  end

  create_table "conversations", :force => true do |t|
    t.string   "subject",    :default => ""
    t.datetime "created_at",                 :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.string   "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["locked_by"], :name => "index_delayed_jobs_on_locked_by"

  create_table "live_sources", :force => true do |t|
    t.integer "settings_id", :default => 1
    t.string  "uri"
    t.string  "name"
  end

  create_table "mail", :force => true do |t|
    t.integer  "user_id",                                          :null => false
    t.integer  "message_id",                                       :null => false
    t.integer  "conversation_id"
    t.boolean  "read",                          :default => false
    t.boolean  "trashed",                       :default => false
    t.string   "mailbox",         :limit => 25
    t.datetime "created_at",                                       :null => false
  end

  create_table "messages", :force => true do |t|
    t.text     "body"
    t.string   "subject",         :default => ""
    t.text     "headers"
    t.integer  "sender_id",                          :null => false
    t.integer  "conversation_id"
    t.boolean  "sent",            :default => false
    t.datetime "created_at",                         :null => false
  end

  create_table "messages_recipients", :id => false, :force => true do |t|
    t.integer "message_id",   :null => false
    t.integer "recipient_id", :null => false
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "playlist_elements", :force => true do |t|
    t.integer "playlist_id"
    t.integer "audio_asset_id"
    t.integer "position"
  end

  create_table "process_configurations", :force => true do |t|
    t.integer  "processable_id"
    t.string   "type"
    t.string   "processable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "program_schedules", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",     :default => false
  end

  create_table "programs", :force => true do |t|
    t.string   "name"
    t.boolean  "active",      :default => true
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name",       :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",                  :default => 1, :null => false
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "segments", :force => true do |t|
    t.integer  "structure_id"
    t.integer  "audio_asset_id"
    t.string   "type"
    t.integer  "position"
    t.integer  "length"
    t.integer  "items_to_play"
    t.boolean  "random"
    t.boolean  "fill"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", :force => true do |t|
    t.string   "station_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "repetitions_url"
  end

  create_table "structure_templates", :force => true do |t|
    t.string   "name"
    t.string   "color"
    t.string   "calendar_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "structures", :force => true do |t|
    t.integer  "playable_id"
    t.string   "playable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "urlnames", :force => true do |t|
    t.string  "name"
    t.string  "nameable_type"
    t.integer "nameable_id"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "login"
    t.string   "email"
    t.string   "identity_url"
    t.string   "remember_token"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "activation_code",           :limit => 40
    t.datetime "remember_token_expires_at"
    t.datetime "activated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
