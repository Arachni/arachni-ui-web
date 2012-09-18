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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120918232817) do

  create_table "profiles", :force => true do |t|
    t.text     "redundant"
    t.integer  "depth_limit"
    t.integer  "link_count_limit"
    t.integer  "redirect_limit"
    t.integer  "http_req_limit"
    t.boolean  "audit_links"
    t.boolean  "audit_forms"
    t.boolean  "audit_cookies"
    t.boolean  "audit_headers"
    t.text     "modules"
    t.text     "authed_by"
    t.string   "proxy_host"
    t.integer  "proxy_port"
    t.string   "proxy_username"
    t.text     "proxy_password"
    t.string   "proxy_type"
    t.text     "cookies"
    t.text     "user_agent"
    t.text     "exclude"
    t.text     "exclude_cookies"
    t.text     "exclude_vectors"
    t.text     "include"
    t.boolean  "follow_subdomains"
    t.text     "plugins"
    t.text     "custom_headers"
    t.text     "restrict_paths"
    t.text     "extend_paths"
    t.integer  "min_pages_per_instance"
    t.integer  "max_slaves"
    t.boolean  "fuzz_methods"
    t.boolean  "audit_cookies_extensively"
    t.boolean  "exclude_binaries"
    t.boolean  "auto_redundant"
    t.text     "login_check_url"
    t.text     "login_check_pattern"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "name"
    t.text     "description"
    t.boolean  "default"
    t.integer  "http_timeout"
  end

  add_index "profiles", ["name"], :name => "index_profiles_on_name"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "name"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end
