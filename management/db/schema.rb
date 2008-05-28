# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 17) do

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
    t.boolean  "available",      :default => false
    t.string   "retrieval_uri"
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

  create_table "blocs", :force => true do |t|
    t.integer  "playable_id"
    t.string   "playable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "broadcasts", :force => true do |t|
    t.string   "type"
    t.datetime "dtstart"
    t.datetime "dtend"
    t.integer  "emission_type_id"
    t.integer  "program_id"
    t.integer  "program_schedule_id"
    t.text     "description"
    t.integer  "emission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emission_types", :force => true do |t|
    t.string   "name"
    t.string   "color"
    t.string   "calendar_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "live_sources", :force => true do |t|
    t.integer "settings_id"
    t.string  "uri"
    t.string  "title"
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
  end

  create_table "programs", :force => true do |t|
    t.string   "name"
    t.boolean  "active",      :default => true
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name",              :limit => 40
    t.string   "authorizable_type", :limit => 40
    t.integer  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "segments", :force => true do |t|
    t.integer  "bloc_id"
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
