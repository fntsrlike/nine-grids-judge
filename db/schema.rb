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

ActiveRecord::Schema.define(version: 20150303081704) do

  create_table "answers", force: true do |t|
    t.integer  "user_id"
    t.integer  "quiz_id"
    t.text     "content"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["quiz_id"], name: "index_answers_on_quiz_id"
  add_index "answers", ["user_id"], name: "index_answers_on_user_id"

  create_table "chapters", force: true do |t|
    t.string   "number",     default: "",    null: false
    t.string   "title",      default: "",    null: false
    t.text     "decription"
    t.integer  "weight",     default: 999,   null: false
    t.boolean  "is_active",  default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grids", force: true do |t|
    t.integer  "user_id"
    t.integer  "chapter_id"
    t.integer  "quiz_1"
    t.integer  "quiz_2"
    t.integer  "quiz_3"
    t.integer  "quiz_4"
    t.integer  "quiz_5"
    t.integer  "quiz_6"
    t.integer  "quiz_7"
    t.integer  "quiz_8"
    t.integer  "quiz_9"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "grids", ["chapter_id"], name: "index_grids_on_chapter_id"
  add_index "grids", ["user_id"], name: "index_grids_on_user_id"

  create_table "judgements", force: true do |t|
    t.integer  "answer_id"
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "judgements", ["answer_id"], name: "index_judgements_on_answer_id"
  add_index "judgements", ["user_id"], name: "index_judgements_on_user_id"

  create_table "quizzes", force: true do |t|
    t.string   "code",       default: "", null: false
    t.string   "title",      default: "", null: false
    t.text     "content"
    t.integer  "chapter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quizzes", ["chapter_id"], name: "index_quizzes_on_chapter_id"

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], name: "index_roles_on_name"

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "realname"
    t.string   "phone"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"

end
