# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_22_020305) do
  create_table "delivery_events", force: :cascade do |t|
    t.string "address", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "event_type", null: false
    t.text "notes"
    t.string "recipient_name", null: false
    t.datetime "scheduled_at"
    t.integer "status", null: false
    t.integer "trip_id", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_delivery_events_on_trip_id"
  end

  create_table "routes", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.date "route_date", null: false
    t.integer "status", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trips", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "driver_name", null: false
    t.integer "route_id", null: false
    t.integer "sequence", null: false
    t.integer "status", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_trips_on_route_id"
  end

  add_foreign_key "delivery_events", "trips"
  add_foreign_key "trips", "routes"
end
