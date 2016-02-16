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

ActiveRecord::Schema.define(version: 4) do

  create_table "fixtures", force: :cascade do |t|
    t.integer  "league_id"
    t.integer  "matchday"
    t.datetime "date"
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.string   "status"
    t.integer  "home_team_goals"
    t.integer  "away_team_goals"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fixtures", ["away_team_id"], name: "index_fixtures_on_away_team_id"
  add_index "fixtures", ["home_team_id"], name: "index_fixtures_on_home_team_id"
  add_index "fixtures", ["league_id"], name: "index_fixtures_on_league_id"

  create_table "leagues", force: :cascade do |t|
    t.string   "caption"
    t.integer  "year"
    t.datetime "last_updated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leagues_teams", id: false, force: :cascade do |t|
    t.integer "league_id", null: false
    t.integer "team_id",   null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.string   "short_name"
    t.string   "crest_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
