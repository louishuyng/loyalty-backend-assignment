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

ActiveRecord::Schema[7.0].define(version: 2022_09_09_161835) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.string "code"
    t.integer "price", null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_products_on_name", unique: true
  end

  create_table "rewards", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_rewards_on_name", unique: true
  end

  create_table "transactions", force: :cascade do |t|
    t.string "status", default: "pending", null: false
    t.integer "fee", null: false
    t.string "currency", default: "sgd", null: false
    t.string "record_type"
    t.bigint "record_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id"], name: "index_transactions_on_record"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "user_loyalties", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "current_point", default: 0, null: false
    t.decimal "accumulate_point", default: "0.0", null: false
    t.string "tier", default: "standard", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_loyalties_on_user_id"
  end

  create_table "user_point_histories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "point", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_point_histories_on_user_id"
  end

  create_table "user_rewards", force: :cascade do |t|
    t.datetime "activation_time"
    t.datetime "expired_time"
    t.integer "usage_amount", default: 1, null: false
    t.bigint "user_id", null: false
    t.bigint "reward_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reward_id"], name: "index_user_rewards_on_reward_id"
    t.index ["user_id"], name: "index_user_rewards_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "user_name", null: false
    t.string "password", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_name"], name: "index_users_on_user_name", unique: true
  end

  add_foreign_key "transactions", "users"
  add_foreign_key "user_loyalties", "users"
  add_foreign_key "user_point_histories", "users"
  add_foreign_key "user_rewards", "rewards"
  add_foreign_key "user_rewards", "users"
end
