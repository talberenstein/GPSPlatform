# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170505134244) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "alerts", force: :cascade do |t|
    t.integer  "device_id"
    t.integer  "event_id"
    t.datetime "gps_date"
    t.geometry "geom",        limit: {:srid=>0, :type=>"geometry"}
    t.boolean  "seen"
    t.datetime "inserted_at",                                       null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "company_id"
    t.string   "description"
  end

  create_table "command_requests", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "request_time"
    t.string   "command_text"
    t.integer  "status"
    t.datetime "result_time"
    t.integer  "device_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["device_id"], name: "index_command_requests_on_device_id", using: :btree
    t.index ["user_id"], name: "index_command_requests_on_user_id", using: :btree
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "couples_types", force: :cascade do |t|
    t.string   "couple_name"
    t.integer  "high"
    t.integer  "width"
    t.integer  "long"
    t.integer  "weight"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "company_id"
  end

  create_table "daily_activity_histories", force: :cascade do |t|
    t.integer  "device_id"
    t.integer  "company_id"
    t.decimal  "driving_hours"
    t.decimal  "driving_distance"
    t.date     "day"
    t.datetime "inserted_at",      null: false
    t.datetime "updated_at",       null: false
    t.index ["company_id"], name: "index_daily_activity_histories_on_company_id", using: :btree
    t.index ["device_id"], name: "index_daily_activity_histories_on_device_id", using: :btree
  end

  create_table "device_events", force: :cascade do |t|
    t.integer  "device_id"
    t.integer  "event_id"
    t.boolean  "is_alert"
    t.datetime "inserted_at", null: false
    t.datetime "updated_at",  null: false
    t.integer  "company_id"
  end

  create_table "devices", force: :cascade do |t|
    t.string   "imei",        limit: 255
    t.string   "name",        limit: 255
    t.datetime "inserted_at",             null: false
    t.datetime "updated_at",              null: false
    t.integer  "company_id"
    t.integer  "driver_id"
    t.string   "phone"
    t.integer  "group_id"
    t.string   "icon"
    t.index ["group_id"], name: "index_devices_on_group_id", using: :btree
  end

  create_table "drivers", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "rut"
    t.index ["company_id"], name: "index_drivers_on_company_id", using: :btree
  end

  create_table "events", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "syrus",       limit: 255
    t.string   "tk103",       limit: 255
    t.datetime "inserted_at",             null: false
    t.datetime "updated_at",              null: false
    t.string   "amos3005"
  end

  create_table "frames", id: false, force: :cascade do |t|
    t.string   "event_id",           limit: 255
    t.string   "device_type",        limit: 255
    t.string   "imei",               limit: 255
    t.string   "frame_type",         limit: 255
    t.datetime "gps_date"
    t.geometry "geom",               limit: {:srid=>0, :type=>"geometry"}
    t.decimal  "velocity"
    t.decimal  "altitude"
    t.decimal  "direction"
    t.integer  "position_type"
    t.integer  "position_antiquity"
    t.decimal  "odometer"
    t.boolean  "power_source2"
    t.boolean  "power_source"
    t.boolean  "output_1"
    t.boolean  "output_2"
    t.boolean  "input_1"
    t.boolean  "input_2"
    t.boolean  "input_3"
    t.integer  "seen_satellites"
    t.decimal  "battery_voltage"
    t.boolean  "gps_valid"
    t.datetime "inserted_at",                                              null: false
    t.datetime "updated_at",                                               null: false
    t.integer  "company_id"
    t.boolean  "ignition"
    t.integer  "device_id"
    t.index ["device_id"], name: "index_frames_on_device_id", using: :btree
  end

  create_table "geo_zones", force: :cascade do |t|
    t.string   "name"
    t.geometry "geom",              limit: {:srid=>0, :type=>"geometry"}
    t.integer  "company_id"
    t.boolean  "enter_alert",                                             default: false
    t.boolean  "exit_alert",                                              default: false
    t.decimal  "radius",                                                  default: "0.0"
    t.datetime "inserted_at",                                                             null: false
    t.datetime "updated_at",                                                              null: false
    t.integer  "travel_geozone_id"
    t.boolean  "is_display"
    t.boolean  "send_report"
    t.boolean  "low_battery"
    t.boolean  "panic"
    t.boolean  "shutdown"
    t.boolean  "restart_on"
    t.boolean  "ignicion"
    t.boolean  "c_open"
    t.boolean  "c_closed"
    t.boolean  "desenganche"
    t.boolean  "cg_open"
    t.boolean  "cg_closed"
    t.boolean  "stop_report"
    t.boolean  "excess_limit"
    t.boolean  "end_excess_limit"
    t.index ["company_id"], name: "index_geo_zones_on_company_id", using: :btree
  end

  create_table "geo_zones_histories", force: :cascade do |t|
    t.integer  "geo_zone_id"
    t.datetime "enter_time"
    t.datetime "timestamp with time zone"
    t.geometry "enter_location",           limit: {:srid=>0, :type=>"geometry"}
    t.decimal  "enter_odometer"
    t.datetime "exit_time"
    t.geometry "exit_location",            limit: {:srid=>0, :type=>"geometry"}
    t.decimal  "exit_odometer"
    t.integer  "device_id"
    t.integer  "company_id"
    t.datetime "inserted_at",                                                    null: false
    t.datetime "updated_at",                                                     null: false
    t.index ["company_id"], name: "index_geo_zones_histories_on_company_id", using: :btree
    t.index ["device_id"], name: "index_geo_zones_histories_on_device_id", using: :btree
    t.index ["geo_zone_id"], name: "index_geo_zones_histories_on_geo_zone_id", using: :btree
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_groups_on_company_id", using: :btree
  end

  create_table "groups_users", id: false, force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.index ["group_id"], name: "index_groups_users_on_group_id", using: :btree
    t.index ["user_id"], name: "index_groups_users_on_user_id", using: :btree
  end

  create_table "last_position_frames", force: :cascade do |t|
    t.string   "event_id",           limit: 255
    t.string   "device_type",        limit: 255
    t.string   "imei",               limit: 255
    t.string   "frame_type",         limit: 255
    t.datetime "gps_date"
    t.geometry "geom",               limit: {:srid=>0, :type=>"geometry"}
    t.decimal  "velocity"
    t.decimal  "altitude"
    t.decimal  "direction"
    t.integer  "position_type"
    t.integer  "position_antiquity"
    t.decimal  "odometer"
    t.boolean  "ignition"
    t.boolean  "power_source"
    t.boolean  "output_1"
    t.boolean  "output_2"
    t.boolean  "input_1"
    t.boolean  "input_2"
    t.boolean  "input_3"
    t.integer  "seen_satellites"
    t.decimal  "battery_voltage"
    t.boolean  "gps_valid"
    t.datetime "inserted_at",                                              null: false
    t.datetime "updated_at",                                               null: false
    t.integer  "company_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string   "location_name"
    t.string   "location_address"
    t.geometry "coordinate",         limit: {:srid=>0, :type=>"geometry"}
    t.boolean  "is_display"
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.integer  "company_id"
    t.integer  "travel_location_id"
  end

  create_table "owners", force: :cascade do |t|
    t.string   "owner_name"
    t.integer  "location_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "company_id"
  end

  create_table "routes", force: :cascade do |t|
    t.string   "route_name"
    t.geometry "route_geo",       limit: {:srid=>0, :type=>"geometry"}
    t.boolean  "route_toll"
    t.integer  "route_distance"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "route_duration"
    t.integer  "travel_route_id"
    t.integer  "company_id"
    t.string   "from"
    t.string   "to"
    t.string   "maneuver"
  end

  create_table "travel_geozone", id: :integer, default: -> { "nextval('travel_alloweds_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer  "travel_sheet_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "travel_geozones", force: :cascade do |t|
    t.integer  "travel_sheet_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "travel_locations", force: :cascade do |t|
    t.string   "state"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "step"
    t.integer  "travel_sheet_id"
  end

  create_table "travel_routes", force: :cascade do |t|
    t.integer  "travel_sheet_id"
    t.integer  "travel_route_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "travel_sheets", force: :cascade do |t|
    t.string   "travel_name"
    t.string   "state"
    t.boolean  "is_template"
    t.integer  "device_id"
    t.integer  "couples_type_id"
    t.integer  "driver_id"
    t.integer  "owner_id"
    t.integer  "allow_stopped_zone"
    t.integer  "travel_route_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "company_id"
    t.datetime "date_travel"
    t.integer  "created_from"
    t.integer  "modified_from"
    t.integer  "prev_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "inserted_at",                         null: false
    t.datetime "updated_at",                          null: false
    t.integer  "company_id"
    t.integer  "role",                   default: 0
    t.boolean  "send_command"
    t.index ["company_id"], name: "index_users_on_company_id", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  end

  add_foreign_key "alerts", "devices", name: "alerts_device_id_fkey"
  add_foreign_key "alerts", "events", name: "alerts_event_id_fkey"
  add_foreign_key "command_requests", "devices"
  add_foreign_key "command_requests", "users"
  add_foreign_key "daily_activity_histories", "companies"
  add_foreign_key "daily_activity_histories", "devices"
  add_foreign_key "device_events", "devices", name: "device_events_device_id_fkey"
  add_foreign_key "device_events", "events", name: "device_events_event_id_fkey"
  add_foreign_key "devices", "groups"
  add_foreign_key "drivers", "companies"
  add_foreign_key "frames", "devices"
  add_foreign_key "geo_zones", "companies"
  add_foreign_key "geo_zones_histories", "companies"
  add_foreign_key "geo_zones_histories", "devices"
  add_foreign_key "geo_zones_histories", "geo_zones"
  add_foreign_key "groups", "companies"
  add_foreign_key "groups_users", "groups"
  add_foreign_key "groups_users", "users"
  add_foreign_key "users", "companies"
end
