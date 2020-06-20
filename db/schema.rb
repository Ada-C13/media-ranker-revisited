# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_09_011507) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uid"
    t.string "email"
    t.string "provider"
  end

  create_table "votes", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "work_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_votes_on_user_id"
    t.index ["work_id"], name: "index_votes_on_work_id"
  end

  create_table "works", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "creator"
    t.string "description"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "vote_count", default: 0
    t.integer "publication_year"
  end

  add_foreign_key "votes", "users"
  add_foreign_key "votes", "works"
end
