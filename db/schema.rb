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

ActiveRecord::Schema.define(:version => 20101218192643) do

  create_table "bad_symbols", :force => true do |t|
    t.string   "symbol",                  :null => false
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.integer  "verified",   :limit => 2, :null => false
  end

  add_index "bad_symbols", ["symbol"], :name => "symbol"

  create_table "email_contents", :force => true do |t|
    t.integer  "entry_id"
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emails", :force => true do |t|
    t.integer  "source_id",  :null => false
    t.text     "title",      :null => false
    t.text     "body",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "emails", ["source_id"], :name => "source_id"

  create_table "entries", :force => true do |t|
    t.integer  "source_id",                          :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.datetime "sent_at",                            :null => false
    t.string   "symbol",       :limit => 256,        :null => false
    t.integer  "message_type",                       :null => false
    t.string   "url",          :limit => 512
    t.string   "guid",         :limit => 512,        :null => false
    t.text     "subject"
    t.text     "body",         :limit => 2147483647
    t.integer  "action"
  end

  add_index "entries", ["sent_at"], :name => "sent_at"
  add_index "entries", ["symbol"], :name => "symbol"

  create_table "factors", :force => true do |t|
    t.string   "symbol",     :limit => 64, :null => false
    t.integer  "factor",                   :null => false
    t.datetime "created_at",               :null => false
  end

  add_index "factors", ["created_at"], :name => "created_at"
  add_index "factors", ["symbol"], :name => "symbol"

  create_table "quotes", :force => true do |t|
    t.string   "symbol",                                     :null => false
    t.string   "exchange"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.datetime "market_time",                                :null => false
    t.decimal  "last_price",  :precision => 10, :scale => 6, :null => false
  end

  add_index "quotes", ["symbol"], :name => "symbol"

  create_table "sources", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "address",    :null => false
    t.float    "weight",     :null => false
    t.string   "twitter"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tweets", :force => true do |t|
    t.integer  "source_id",  :null => false
    t.text     "text",       :null => false
    t.datetime "updated_at", :null => false
    t.datetime "created_at", :null => false
  end

  add_index "tweets", ["source_id"], :name => "source_id"

end
