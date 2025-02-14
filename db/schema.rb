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

ActiveRecord::Schema[8.0].define(version: 2025_02_13_165256) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "pages", force: :cascade do |t|
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_pages_on_slug"
  end

  create_table "project_coordinators", primary_key: ["project_id", "user_id"], force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "user_id", null: false
    t.index ["project_id"], name: "index_project_coordinators_on_project_id"
    t.index ["user_id"], name: "index_project_coordinators_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["published_at"], name: "index_projects_on_published_at"
  end

  create_table "settings", force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "task_applications", primary_key: ["task_id", "user_id"], force: :cascade do |t|
    t.integer "task_id", null: false
    t.integer "user_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "withdrawn_at"
    t.integer "status", default: 0
    t.index ["task_id"], name: "index_task_applications_on_task_id"
    t.index ["user_id"], name: "index_task_applications_on_user_id"
  end

  create_table "task_coordinators", primary_key: ["task_id", "user_id"], force: :cascade do |t|
    t.integer "task_id", null: false
    t.integer "user_id", null: false
    t.index ["task_id"], name: "index_task_coordinators_on_task_id"
    t.index ["user_id"], name: "index_task_coordinators_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "project_id", null: false
    t.text "description_plain_text"
    t.index ["project_id"], name: "index_tasks_on_project_id"
    t.index ["published_at"], name: "index_tasks_on_published_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "provider", default: "", null: false
    t.string "uid", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", default: "", null: false
    t.string "username", default: "", null: false
    t.string "avatar_url", default: "", null: false
    t.integer "role", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "task_applications", "tasks"
  add_foreign_key "task_applications", "users"
  add_foreign_key "task_coordinators", "tasks"
  add_foreign_key "task_coordinators", "users"
  add_foreign_key "tasks", "projects"
end
