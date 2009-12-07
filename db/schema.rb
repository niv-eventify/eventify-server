# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091207103930) do

  create_table "categories", :force => true do |t|
    t.string   "name_en"
    t.string   "name_he"
    t.datetime "disabled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["disabled_at"], :name => "index_categories_on_disabled_at"

  create_table "contact_importers", :force => true do |t|
    t.integer  "user_id"
    t.string   "contact_source",    :limit => 16
    t.datetime "completed_at"
    t.string   "last_error"
    t.integer  "contacts_imported"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "email"
    t.string   "mobile"
    t.string   "country"
    t.string   "city"
    t.string   "street"
    t.string   "zip"
    t.string   "company"
    t.string   "title"
    t.datetime "removed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["user_id", "removed_at", "email"], :name => "user_removed_email"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "designs", :force => true do |t|
    t.integer  "category_id"
    t.integer  "creator_id"
    t.datetime "disabled_at"
    t.string   "card_file_name"
    t.string   "card_content_type"
    t.integer  "card_file_size"
    t.datetime "card_updated_at"
    t.string   "background_file_name"
    t.string   "background_content_type"
    t.integer  "background_file_size"
    t.datetime "background_updated_at"
    t.string   "preview_file_name"
    t.string   "preview_content_type"
    t.integer  "preview_file_size"
    t.datetime "preview_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "designs", ["category_id"], :name => "index_designs_on_category_id"

  create_table "global_preferences", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.integer  "ttl"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "global_preferences", ["name"], :name => "index_global_preferences_on_name", :unique => true

  create_table "users", :force => true do |t|
    t.string   "name",                :limit => 48
    t.string   "email",               :limit => 100, :null => false
    t.string   "crypted_password",    :limit => 128
    t.string   "password_salt",       :limit => 20
    t.string   "persistence_token",   :limit => 128
    t.string   "single_access_token", :limit => 20
    t.string   "perishable_token",    :limit => 20
    t.integer  "login_count"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.datetime "activated_at"
    t.string   "current_login_ip",    :limit => 15
    t.string   "last_login_ip",       :limit => 15
    t.boolean  "is_admin"
    t.boolean  "pending"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "disabled_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"
  add_index "users", ["single_access_token"], :name => "index_users_on_single_access_token"

end
