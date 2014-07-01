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

ActiveRecord::Schema.define(version: 20140627030706) do

  create_table "dependencies", force: true do |t|
    t.text     "description"
    t.string   "lib"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dependencies", ["attachable_id", "attachable_type"], name: "index_dependencies_on_attachable_id_and_attachable_type"

  create_table "jobs", force: true do |t|
    t.string   "name"
    t.string   "job_type"
    t.string   "spec"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "core"
    t.text     "description"
  end

  create_table "jobs_users", id: false, force: true do |t|
    t.integer "job_id"
    t.integer "user_id"
  end

  create_table "prompts", force: true do |t|
    t.string   "label"
    t.integer  "field_type"
    t.integer  "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
  end

end
