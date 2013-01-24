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

ActiveRecord::Schema.define(:version => 20130121042140) do

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.text     "text"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "dispatchers", :force => true do |t|
    t.string   "address"
    t.integer  "port"
    t.text     "description"
    t.text     "statistics"
    t.boolean  "alive"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "issues", :force => true do |t|
    t.string   "name"
    t.text     "url"
    t.text     "vector_name"
    t.float    "cvssv2"
    t.integer  "cwe"
    t.text     "description"
    t.string   "vector_type"
    t.string   "http_method"
    t.text     "tags"
    t.text     "headers"
    t.text     "signature"
    t.text     "seed"
    t.text     "proof"
    t.text     "response_body"
    t.boolean  "requires_verification"
    t.text     "audit_options"
    t.text     "references"
    t.text     "remedy_code"
    t.text     "remedy_guidance"
    t.text     "remarks"
    t.string   "severity"
    t.string   "digest"
    t.boolean  "false_positive",        :default => false
    t.boolean  "verified",              :default => false
    t.datetime "verified_at"
    t.text     "verification_steps"
    t.integer  "verified_by"
    t.integer  "verification_steps_by"
    t.boolean  "fixed",                 :default => false
    t.integer  "scan_id"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.string   "model_type"
    t.integer  "model_id"
    t.string   "action"
    t.integer  "actor_id"
    t.text     "text"
    t.boolean  "read",       :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

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
    t.integer  "max_slaves"
    t.boolean  "fuzz_methods"
    t.boolean  "audit_cookies_extensively"
    t.boolean  "exclude_binaries"
    t.integer  "auto_redundant"
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

  create_table "reports", :force => true do |t|
    t.text     "object"
    t.text     "sitemap"
    t.integer  "scan_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "scans", :force => true do |t|
    t.string   "type"
    t.boolean  "active",                        :default => false
    t.boolean  "extend_from_revision_sitemaps"
    t.boolean  "restrict_to_revision_sitemaps"
    t.integer  "instance_count",                :default => 1
    t.integer  "dispatcher_id"
    t.string   "instance_url"
    t.string   "instance_token"
    t.integer  "profile_id"
    t.text     "url"
    t.text     "description"
    t.text     "report"
    t.string   "status"
    t.text     "statistics"
    t.text     "issue_digests"
    t.text     "error_messages",                :default => ""
    t.integer  "owner_id"
    t.datetime "finished_at"
    t.integer  "root_id"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

  create_table "scans_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "scan_id"
  end

  create_table "settings", :force => true do |t|
    t.string   "var",                      :null => false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", :limit => 30
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "settings", ["thing_type", "thing_id", "var"], :name => "index_settings_on_thing_type_and_thing_id_and_var", :unique => true

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
