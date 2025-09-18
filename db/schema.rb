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

ActiveRecord::Schema[7.2].define(version: 2025_09_18_055356) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answer_options", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.string "code"
    t.string "label"
    t.string "value"
    t.integer "position"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id", "position"], name: "index_answer_options_on_question_id_and_position"
    t.index ["question_id"], name: "index_answer_options_on_question_id"
  end

  create_table "conditions", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.string "expression"
    t.jsonb "logic"
    t.bigint "target_question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_conditions_on_question_id"
    t.index ["target_question_id"], name: "index_conditions_on_target_question_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "product_kits", force: :cascade do |t|
    t.string "category"
    t.string "code"
    t.string "name"
    t.text "description"
    t.text "condition_expression"
    t.decimal "price"
    t.integer "stock"
    t.boolean "active"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_product_kits_on_category"
    t.index ["code"], name: "index_product_kits_on_code", unique: true
  end

  create_table "questionnaire_sessions", force: :cascade do |t|
    t.string "session_token"
    t.bigint "questionnaire_id", null: false
    t.bigint "current_question_id"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.string "ip_address"
    t.string "user_agent"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["completed_at"], name: "index_questionnaire_sessions_on_completed_at"
    t.index ["current_question_id"], name: "index_questionnaire_sessions_on_current_question_id"
    t.index ["questionnaire_id"], name: "index_questionnaire_sessions_on_questionnaire_id"
    t.index ["session_token"], name: "index_questionnaire_sessions_on_session_token", unique: true
  end

  create_table "questionnaires", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.text "description"
    t.boolean "active"
    t.integer "position"
    t.jsonb "settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_questionnaires_on_slug", unique: true
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "questionnaire_id", null: false
    t.string "code"
    t.string "title"
    t.text "description"
    t.string "question_type"
    t.string "page_name"
    t.integer "position"
    t.boolean "required"
    t.boolean "conditional"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_questions_on_code", unique: true
    t.index ["page_name"], name: "index_questions_on_page_name"
    t.index ["questionnaire_id", "position"], name: "index_questions_on_questionnaire_id_and_position"
    t.index ["questionnaire_id"], name: "index_questions_on_questionnaire_id"
  end

  create_table "results", force: :cascade do |t|
    t.bigint "questionnaire_session_id", null: false
    t.jsonb "product_kits"
    t.datetime "generated_at"
    t.boolean "sent_by_email"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["questionnaire_session_id"], name: "index_results_on_questionnaire_session_id"
  end

  create_table "user_responses", force: :cascade do |t|
    t.bigint "questionnaire_session_id", null: false
    t.bigint "question_id", null: false
    t.text "answer"
    t.string "answer_code"
    t.datetime "answered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_user_responses_on_question_id"
    t.index ["questionnaire_session_id", "question_id"], name: "index_unique_session_question", unique: true
    t.index ["questionnaire_session_id"], name: "index_user_responses_on_questionnaire_session_id"
  end

  add_foreign_key "answer_options", "questions"
  add_foreign_key "conditions", "questions"
  add_foreign_key "conditions", "questions", column: "target_question_id"
  add_foreign_key "questionnaire_sessions", "questionnaires"
  add_foreign_key "questionnaire_sessions", "questions", column: "current_question_id"
  add_foreign_key "questions", "questionnaires"
  add_foreign_key "results", "questionnaire_sessions"
  add_foreign_key "user_responses", "questionnaire_sessions"
  add_foreign_key "user_responses", "questions"
end
