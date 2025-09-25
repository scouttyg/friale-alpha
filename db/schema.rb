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

ActiveRecord::Schema[8.0].define(version: 2025_09_25_232424) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "type"
    t.string "stripe_customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "metadata"
    t.index [ "stripe_customer_id" ], name: "index_accounts_on_stripe_customer_id", unique: true
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "author_type", "author_id" ], name: "index_active_admin_comments_on_author"
    t.index [ "namespace" ], name: "index_active_admin_comments_on_namespace"
    t.index [ "resource_type", "resource_id" ], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index [ "blob_id" ], name: "index_active_storage_attachments_on_blob_id"
    t.index [ "record_type", "record_id", "name", "blob_id" ], name: "index_active_storage_attachments_uniqueness", unique: true
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
    t.index [ "key" ], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index [ "blob_id", "variation_digest" ], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "email" ], name: "index_admin_users_on_email", unique: true
    t.index [ "reset_password_token" ], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "assets", force: :cascade do |t|
    t.integer "origination"
    t.integer "asset_type"
    t.decimal "quantity", precision: 10, scale: 2
    t.boolean "current"
    t.bigint "converted_asset_id"
    t.bigint "position_id", null: false
    t.bigint "cap_cents", default: 0, null: false
    t.string "cap_currency", default: "USD", null: false
    t.integer "discount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "converted_asset_id" ], name: "index_assets_on_converted_asset_id"
    t.index [ "position_id" ], name: "index_assets_on_position_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "website"
    t.text "description"
    t.bigint "firm_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "firm_account_id" ], name: "index_companies_on_firm_account_id"
  end

  create_table "company_locations", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "company_id" ], name: "index_company_locations_on_company_id"
    t.index [ "location_id" ], name: "index_company_locations_on_location_id"
  end

  create_table "company_notes", force: :cascade do |t|
    t.boolean "investor_visible"
    t.text "note"
    t.boolean "active"
    t.integer "performance"
    t.integer "stage"
    t.bigint "company_id", null: false
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "company_id" ], name: "index_company_notes_on_company_id"
  end

  create_table "contact_form_messages", force: :cascade do |t|
    t.string "email"
    t.string "message"
    t.string "subject"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents", force: :cascade do |t|
    t.string "name"
    t.date "date"
    t.bigint "firm_account_id"
    t.bigint "fund_id"
    t.bigint "investor_account_id"
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "company_id" ], name: "index_documents_on_company_id"
    t.index [ "firm_account_id" ], name: "index_documents_on_firm_account_id"
    t.index [ "fund_id" ], name: "index_documents_on_fund_id"
    t.index [ "investor_account_id" ], name: "index_documents_on_investor_account_id"
  end

  create_table "fund_distributions", force: :cascade do |t|
    t.string "name"
    t.date "date"
    t.bigint "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.text "notes"
    t.bigint "fund_id", null: false
    t.bigint "position_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "fund_id" ], name: "index_fund_distributions_on_fund_id"
    t.index [ "position_id" ], name: "index_fund_distributions_on_position_id"
  end

  create_table "fund_investor_investments", force: :cascade do |t|
    t.integer "capital_commitment_cents", default: 0, null: false
    t.string "capital_commitment_currency", default: "USD", null: false
    t.integer "capital_funded_cents", default: 0, null: false
    t.string "capital_funded_currency", default: "USD", null: false
    t.bigint "fund_id", null: false
    t.bigint "investor_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "fund_id" ], name: "index_fund_investor_investments_on_fund_id"
    t.index [ "investor_account_id" ], name: "index_fund_investor_investments_on_investor_account_id"
  end

  create_table "fund_investor_transactions", force: :cascade do |t|
    t.date "date"
    t.integer "status"
    t.bigint "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.bigint "bank_account_id"
    t.bigint "fund_distribution_id"
    t.bigint "fund_investor_investment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "bank_account_id" ], name: "index_fund_investor_transactions_on_bank_account_id"
    t.index [ "fund_distribution_id" ], name: "index_fund_investor_transactions_on_fund_distribution_id"
    t.index [ "fund_investor_investment_id" ], name: "idx_on_fund_investor_investment_id_1737004731"
  end

  create_table "funds", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.bigint "firm_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "firm_account_id" ], name: "index_funds_on_firm_account_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "city"
    t.string "region"
    t.string "country"
    t.string "time_zone"
    t.float "latitude"
    t.float "longitude"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "marks", force: :cascade do |t|
    t.date "mark_date"
    t.bigint "price_cents", default: 0, null: false
    t.string "price_currency", default: "USD", null: false
    t.integer "source"
    t.text "notes"
    t.bigint "asset_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "asset_id" ], name: "index_marks_on_asset_id"
  end

  create_table "members", force: :cascade do |t|
    t.integer "access_level"
    t.string "invite_email"
    t.string "invite_token"
    t.string "source_type", null: false
    t.bigint "source_id", null: false
    t.string "type"
    t.bigint "creator_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "creator_id" ], name: "index_members_on_creator_id"
    t.index [ "source_type", "source_id" ], name: "index_members_on_source"
    t.index [ "user_id" ], name: "index_members_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.text "body"
    t.datetime "read_at"
    t.string "title"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notification_type"
    t.index [ "user_id" ], name: "index_notifications_on_user_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.boolean "default", default: false
    t.datetime "deleted_at"
    t.jsonb "metadata"
    t.string "type"
    t.bigint "account_id", null: false
    t.string "stripe_payment_method_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "account_id" ], name: "index_payment_methods_on_account_id"
    t.index [ "stripe_payment_method_id" ], name: "index_payment_methods_on_stripe_payment_method_id", unique: true
  end

  create_table "plan_periods", force: :cascade do |t|
    t.bigint "plan_id", null: false
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "USD", null: false
    t.integer "interval"
    t.string "stripe_price_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "plan_id" ], name: "index_plan_periods_on_plan_id"
    t.index [ "stripe_price_id" ], name: "index_plan_periods_on_stripe_price_id", unique: true
  end

  create_table "plans", force: :cascade do |t|
    t.datetime "activated_at"
    t.datetime "deactivated_at"
    t.text "description"
    t.string "name"
    t.integer "position"
    t.jsonb "usage_limits"
    t.string "stripe_product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "stripe_product_id" ], name: "index_plans_on_stripe_product_id", unique: true
  end

  create_table "positions", force: :cascade do |t|
    t.bigint "invested_capital_cents", default: 0, null: false
    t.string "invested_capital_currency", default: "USD", null: false
    t.bigint "returned_capital_cents", default: 0, null: false
    t.string "returned_capital_currency", default: "USD", null: false
    t.datetime "open_date"
    t.datetime "close_date"
    t.bigint "company_id", null: false
    t.bigint "fund_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "company_id" ], name: "index_positions_on_company_id"
    t.index [ "fund_id" ], name: "index_positions_on_fund_id"
  end

  create_table "push_subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "endpoint"
    t.string "public_key"
    t.string "auth_secret"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "user_id", "endpoint", "public_key", "auth_secret" ], name: "index_push_subscriptions_on_user_id_endpoint_and_auth", unique: true
    t.index [ "user_id" ], name: "index_push_subscriptions_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "plan_id", null: false
    t.bigint "plan_period_id", null: false
    t.jsonb "usage_limits"
    t.string "stripe_subscription_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "account_id" ], name: "index_subscriptions_on_account_id"
    t.index [ "plan_id" ], name: "index_subscriptions_on_plan_id"
    t.index [ "plan_period_id" ], name: "index_subscriptions_on_plan_period_id"
    t.index [ "stripe_subscription_id" ], name: "index_subscriptions_on_stripe_subscription_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.index [ "confirmation_token" ], name: "index_users_on_confirmation_token", unique: true
    t.index [ "email" ], name: "index_users_on_email", unique: true
    t.index [ "reset_password_token" ], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "whodunnit"
    t.datetime "created_at"
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.text "object"
    t.text "object_changes"
    t.string "whodunnit_type"
    t.index [ "item_type", "item_id" ], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "assets", "assets", column: "converted_asset_id"
  add_foreign_key "assets", "positions"
  add_foreign_key "companies", "accounts", column: "firm_account_id"
  add_foreign_key "company_locations", "companies"
  add_foreign_key "company_locations", "locations"
  add_foreign_key "company_notes", "companies"
  add_foreign_key "documents", "accounts", column: "firm_account_id"
  add_foreign_key "documents", "accounts", column: "investor_account_id"
  add_foreign_key "documents", "companies"
  add_foreign_key "documents", "funds"
  add_foreign_key "fund_distributions", "funds"
  add_foreign_key "fund_distributions", "positions"
  add_foreign_key "fund_investor_investments", "accounts", column: "investor_account_id"
  add_foreign_key "fund_investor_investments", "funds"
  add_foreign_key "fund_investor_transactions", "fund_distributions"
  add_foreign_key "fund_investor_transactions", "fund_investor_investments"
  add_foreign_key "fund_investor_transactions", "payment_methods", column: "bank_account_id"
  add_foreign_key "funds", "accounts", column: "firm_account_id"
  add_foreign_key "marks", "assets"
  add_foreign_key "members", "users"
  add_foreign_key "members", "users", column: "creator_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "payment_methods", "accounts"
  add_foreign_key "plan_periods", "plans"
  add_foreign_key "positions", "companies"
  add_foreign_key "positions", "funds"
  add_foreign_key "push_subscriptions", "users"
  add_foreign_key "subscriptions", "accounts"
  add_foreign_key "subscriptions", "plan_periods"
  add_foreign_key "subscriptions", "plans"
end
