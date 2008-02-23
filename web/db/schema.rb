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

ActiveRecord::Schema.define(:version => 6) do

  create_table "program_schedulings", :force => true do |t|
    t.integer  "schedule_version_id"
    t.integer  "program_id"
    t.datetime "start"
    t.datetime "end"
    t.string   "recurrence"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "programs", :force => true do |t|
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "schedule_versions", :force => true do |t|
    t.integer  "schedule_id"
    t.string   "uri"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schedules", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "web_active_version"
  end

end
