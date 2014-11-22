# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20141122155933) do

  create_table "achievements", force: true do |t|
    t.string   "title"
    t.integer  "points"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "validator_id"
    t.text     "rules"
    t.string   "sport"
  end

  create_table "boxing_participant_results", force: true do |t|
    t.integer  "sport_session_participant_id"
    t.boolean  "knockout_opponent"
    t.integer  "number_of_rounds"
    t.integer  "time_of_fight"
    t.integer  "points"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "credits", force: true do |t|
    t.integer  "user_id"
    t.integer  "achievement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendships", force: true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.boolean  "confirmed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "running_participant_results", force: true do |t|
    t.integer  "sport_session_participant_id"
    t.float    "length"
    t.float    "time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

  create_table "soccers", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sport_session_participants", force: true do |t|
    t.integer  "user_id"
    t.integer  "sport_session_id"
    t.boolean  "confirmed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sport_sessions", force: true do |t|
    t.integer  "user_id"
    t.string   "type"
    t.string   "cybercoach_uri"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location"
    t.datetime "date"
    t.string   "title"
    t.float    "latitude"
    t.float    "longitude"
  end

  create_table "user_achievements", force: true do |t|
    t.integer  "user_id"
    t.integer  "achievement_id"
    t.integer  "sport_session_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password"
  end

  create_table "validators", force: true do |t|
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
