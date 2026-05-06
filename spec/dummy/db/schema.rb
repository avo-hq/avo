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

ActiveRecord::Schema[8.1].define(version: 2026_05_05_120100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cities", force: :cascade do |t|
    t.json "city_center_area"
    t.datetime "created_at", null: false
    t.json "features"
    t.string "image_url"
    t.boolean "is_capital"
    t.float "latitude"
    t.float "longitude"
    t.json "metadata"
    t.string "name"
    t.integer "population"
    t.string "status"
    t.text "tiny_description"
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.integer "commentable_id"
    t.string "commentable_type"
    t.datetime "created_at", null: false
    t.datetime "posted_at", precision: nil
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "course_links", force: :cascade do |t|
    t.bigint "course_id"
    t.datetime "created_at", null: false
    t.string "link"
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_course_links_on_course_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "name"
    t.text "skills", default: [], array: true
    t.time "starting_at"
    t.datetime "updated_at", null: false
  end

  create_table "courses_locations", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["course_id"], name: "index_courses_locations_on_course_id"
    t.index ["user_id"], name: "index_courses_locations_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "event_time", precision: nil
    t.bigint "location_id"
    t.string "name"
    t.datetime "updated_at", null: false
    t.uuid "uuid"
    t.index ["location_id"], name: "index_events_on_location_id"
    t.index ["uuid"], name: "index_events_on_uuid", unique: true
  end

  create_table "fish", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "size"
    t.string "type"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_fish_on_user_id"
  end

  create_table "galaxy_planet_satellites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "planet_id", null: false
    t.datetime "updated_at", null: false
    t.index ["planet_id"], name: "index_galaxy_planet_satellites_on_planet_id"
  end

  create_table "galaxy_planets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.text "name"
    t.string "size"
    t.bigint "store_id"
    t.bigint "team_id"
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_locations_on_store_id"
    t.index ["team_id"], name: "index_locations_on_team_id"
  end

  create_table "people", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "person_id"
    t.string "type"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["person_id"], name: "index_people_on_person_id"
    t.index ["user_id"], name: "index_people_on_user_id"
  end

  create_table "playgrounds", force: :cascade do |t|
    t.json "area_coordinates"
    t.string "array_values", default: [], array: true
    t.string "badge_value"
    t.json "boolean_group_values", default: {}
    t.boolean "boolean_value", default: false, null: false
    t.text "code_value"
    t.string "country_value"
    t.datetime "created_at", null: false
    t.datetime "date_time_value", precision: nil
    t.date "date_value"
    t.text "easy_mde_content"
    t.string "external_image_url"
    t.string "gravatar_email"
    t.string "hidden_token"
    t.json "key_value_data", default: {}
    t.float "latitude"
    t.float "longitude"
    t.string "multi_select_values", default: [], array: true
    t.string "name"
    t.integer "number_value"
    t.string "password_value"
    t.integer "progress_value", default: 0, null: false
    t.string "radio_value"
    t.string "select_value"
    t.integer "stars_value", default: 0, null: false
    t.string "status_value"
    t.string "tags_values", default: [], array: true
    t.string "text_value"
    t.text "textarea_value"
    t.time "time_value"
    t.text "tiptap_content"
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.boolean "is_featured"
    t.string "name"
    t.datetime "published_at", precision: nil
    t.string "slug"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "USD", null: false
    t.integer "rating", default: 0, null: false
    t.string "sizes", default: [], array: true
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["rating"], name: "index_products_on_rating"
    t.check_constraint "rating >= 0 AND rating <= 5", name: "rating_range_check"
  end

  create_table "projects", force: :cascade do |t|
    t.string "budget"
    t.string "country"
    t.datetime "created_at", null: false
    t.text "description"
    t.json "meta"
    t.string "name"
    t.integer "progress"
    t.string "stage"
    t.datetime "started_at", precision: nil
    t.string "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "users_required"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "projects_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "project_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["project_id"], name: "index_projects_users_on_project_id"
    t.index ["user_id"], name: "index_projects_users_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "reviewable_id"
    t.string "reviewable_type"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "store_patrons", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "review"
    t.integer "store_id"
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "stores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "size"
    t.datetime "updated_at", null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.bigint "tag_id"
    t.bigint "taggable_id"
    t.string "taggable_type"
    t.bigint "tagger_id"
    t.string "tagger_type"
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "taggings_count", default: 0
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "team_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "level"
    t.bigint "team_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["team_id"], name: "index_team_memberships_on_team_id"
    t.index ["user_id"], name: "index_team_memberships_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
    t.string "url"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true
    t.jsonb "avo_preferences", default: {}
    t.date "birthday"
    t.datetime "created_at", null: false
    t.text "custom_css"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.json "roles"
    t.string "slug"
    t.bigint "team_id"
    t.json "theme_settings", default: {}, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
    t.index ["team_id"], name: "index_users_on_team_id"
  end

  create_table "volunteers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "department"
    t.uuid "event_id", null: false
    t.string "name"
    t.string "role"
    t.string "skills", default: [], array: true
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_volunteers_on_event_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "users"
  add_foreign_key "courses_locations", "courses"
  add_foreign_key "courses_locations", "users"
  add_foreign_key "events", "locations"
  add_foreign_key "fish", "users"
  add_foreign_key "galaxy_planet_satellites", "galaxy_planets", column: "planet_id"
  add_foreign_key "locations", "stores"
  add_foreign_key "locations", "teams"
  add_foreign_key "people", "people"
  add_foreign_key "people", "users"
  add_foreign_key "projects", "users"
  add_foreign_key "reviews", "users"
  add_foreign_key "taggings", "tags"
  add_foreign_key "team_memberships", "teams"
  add_foreign_key "team_memberships", "users"
end
