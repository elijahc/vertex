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

ActiveRecord::Schema.define(version: 20140730205248) do

  create_table "cores", force: true do |t|
    t.string   "class_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", force: true do |t|
    t.string   "name"
    t.string   "job_type"
    t.string   "spec"
    t.integer  "core_id"
    t.string   "parser"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  create_table "jobs_users", id: false, force: true do |t|
    t.integer "job_id"
    t.integer "user_id"
  end

  create_table "prompt_values", force: true do |t|
    t.string   "value"
    t.string   "value_type"
    t.string   "file"
    t.integer  "prompt_id"
    t.integer  "run_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prompt_values", ["prompt_id"], name: "index_prompt_values_on_prompt_id"
  add_index "prompt_values", ["run_id"], name: "index_prompt_values_on_run_id"

  create_table "prompts", force: true do |t|
    t.integer  "field_type"
    t.string   "label"
    t.integer  "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "runs", force: true do |t|
    t.string   "uuid"
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
    t.boolean  "approved",   default: false, null: false
  end

  add_index "users", ["approved"], name: "index_users_on_approved"

end
