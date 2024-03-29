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

ActiveRecord::Schema.define(version: 20140423230030) do

  create_table "posts", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content"
    t.string   "buffer_time"
    t.string   "job_id"
    t.datetime "parse_time"
    t.integer  "user_id"
    t.string   "page_token"
    t.string   "page_name"
    t.string   "photo"
    t.boolean  "queue"
    t.boolean  "posted",      default: false
    t.integer  "queue_order"
  end

  create_table "queue_times", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hour"
    t.string   "minute"
    t.string   "ampm"
  end

  create_table "users", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "selected_a_time_zone", default: false
    t.string   "time_zone"
    t.boolean  "mon",                  default: true
    t.boolean  "tue",                  default: true
    t.boolean  "wed",                  default: true
    t.boolean  "thu",                  default: true
    t.boolean  "fri",                  default: true
    t.boolean  "sat",                  default: true
    t.boolean  "sun",                  default: true
  end

end
