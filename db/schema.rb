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

ActiveRecord::Schema.define(:version => 20121111061059) do

  create_table "backgrounds", :force => true do |t|
    t.integer  "event_id"
    t.string   "rsvp_file_name"
    t.string   "rsvp_content_type"
    t.integer  "rsvp_file_size"
    t.datetime "rsvp_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name_en"
    t.string   "name_he"
    t.datetime "disabled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "popularity",  :default => 0
    t.boolean  "root",        :default => false
  end

  add_index "categories", ["disabled_at"], :name => "index_categories_on_disabled_at"
  add_index "categories", ["root"], :name => "index_categories_on_root"

  create_table "classifications", :force => true do |t|
    t.integer  "category_id"
    t.integer  "design_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "classifications", ["category_id"], :name => "index_classifications_on_category_id"
  add_index "classifications", ["design_id"], :name => "index_classifications_on_design_id"

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

  create_table "cropped_pictures", :force => true do |t|
    t.integer  "event_id"
    t.integer  "window_id"
    t.string   "pic_file_name"
    t.string   "pic_content_type"
    t.integer  "pic_file_size"
    t.datetime "pic_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "designers", :force => true do |t|
    t.integer  "user_id"
    t.string   "friendly_url"
    t.string   "name"
    t.text     "about"
    t.string   "link1"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "work1_file_name"
    t.string   "work1_content_type"
    t.integer  "work1_file_size"
    t.datetime "work1_updated_at"
    t.string   "work2_file_name"
    t.string   "work2_content_type"
    t.integer  "work2_file_size"
    t.datetime "work2_updated_at"
    t.string   "work3_file_name"
    t.string   "work3_content_type"
    t.integer  "work3_file_size"
    t.datetime "work3_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_activated"
  end

  add_index "designers", ["friendly_url"], :name => "index_designers_on_friendly_url", :unique => true

  create_table "designs", :force => true do |t|
    t.integer  "creator_id"
    t.datetime "disabled_at"
    t.string   "card_file_name"
    t.string   "card_content_type"
    t.integer  "card_file_size"
    t.datetime "card_updated_at"
    t.string   "preview_file_name"
    t.string   "preview_content_type"
    t.integer  "preview_file_size"
    t.datetime "preview_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "text_top_x"
    t.integer  "text_top_y"
    t.integer  "text_width"
    t.integer  "text_height"
    t.integer  "title_top_x"
    t.integer  "title_top_y"
    t.integer  "title_width"
    t.integer  "title_height"
    t.string   "font_body"
    t.string   "title_color"
    t.string   "message_color"
    t.string   "text_align"
    t.boolean  "in_carousel",           :default => false
    t.string   "carousel_file_name"
    t.string   "carousel_content_type"
    t.integer  "carousel_file_size"
    t.datetime "carousel_updated_at"
    t.string   "font_title"
    t.integer  "ordering",              :default => 0
    t.integer  "redirect_to_category"
    t.integer  "designer_id"
  end

  create_table "embedding_providers", :force => true do |t|
    t.string   "name"
    t.string   "src"
    t.string   "get_params_for_preview"
    t.string   "get_params_for_stage2"
    t.string   "html_attrs_for_preview"
    t.string   "html_attrs_for_stage2"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.integer  "user_id"
    t.integer  "category_id"
    t.integer  "design_id"
    t.string   "name"
    t.datetime "starting_at"
    t.datetime "ending_at"
    t.string   "location_name"
    t.string   "location_address"
    t.string   "map_link",                      :limit => 2048
    t.string   "map_file_name"
    t.string   "map_content_type"
    t.integer  "map_file_size"
    t.datetime "map_updated_at"
    t.string   "guest_message",                 :limit => 1024
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stage_passed"
    t.string   "language",                      :limit => 16
    t.string   "host_mobile_number"
    t.string   "sms_message"
    t.datetime "rsvp_summary_send_at"
    t.integer  "rsvp_summary_send_every",                       :default => 2
    t.datetime "last_summary_sent_at"
    t.boolean  "allow_seeing_other_guests",                     :default => true
    t.integer  "title_font_size",                               :default => 22
    t.integer  "msg_font_size",                                 :default => 20
    t.string   "title_text_align"
    t.string   "msg_text_align"
    t.string   "font_body"
    t.string   "title_color"
    t.string   "msg_color"
    t.integer  "sms_messages_count",                            :default => 0
    t.boolean  "user_is_activated",                             :default => false
    t.string   "tz",                            :limit => 128
    t.boolean  "any_invitation_sent",                           :default => false
    t.string   "sms_resend_message"
    t.string   "font_title"
    t.datetime "canceled_at"
    t.string   "cancellation_sms"
    t.string   "cancellation_email",            :limit => 8192
    t.string   "cancellation_email_subject"
    t.datetime "cancellation_sent_at"
    t.boolean  "cancel_by_sms"
    t.boolean  "cancel_by_email"
    t.string   "invitation_title",              :limit => 1024
    t.integer  "emails_plan",                                   :default => 0
    t.integer  "sms_plan",                                      :default => 0
    t.integer  "prints_plan",                                   :default => 0
    t.integer  "prints_ordered",                                :default => 0
    t.string   "invitation_thumb_file_name"
    t.string   "invitation_thumb_content_type"
    t.integer  "invitation_thumb_file_size"
    t.datetime "invitation_thumb_updated_at"
    t.integer  "text_top_x"
    t.integer  "text_top_y"
    t.integer  "text_width"
    t.integer  "text_height"
    t.integer  "title_top_x"
    t.integer  "title_top_y"
    t.integer  "title_width"
    t.integer  "title_height"
    t.integer  "event_type",                                    :default => 10
  end

  add_index "events", ["starting_at", "canceled_at", "rsvp_summary_send_at"], :name => "start_cancel_summary_sent"

  create_table "gardens", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "url"
    t.string   "map_file_name"
    t.string   "map_content_type"
    t.integer  "map_file_size"
    t.datetime "map_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "global_preferences", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.integer  "ttl"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "global_preferences", ["name"], :name => "index_global_preferences_on_name", :unique => true

  create_table "guests", :force => true do |t|
    t.integer  "event_id"
    t.string   "name"
    t.string   "email"
    t.string   "mobile_phone"
    t.boolean  "send_email"
    t.boolean  "send_sms"
    t.boolean  "allow_snow_ball"
    t.string   "email_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "email_invitation_sent_at"
    t.datetime "sms_invitation_sent_at"
    t.integer  "rsvp"
    t.integer  "attendees_count"
    t.datetime "sms_invitation_failed_at"
    t.datetime "email_invitation_failed_at"
    t.datetime "summary_email_sent_at"
    t.string   "message_to_host"
    t.integer  "sms_messages_count",         :default => 0
    t.datetime "send_email_invitation_at"
    t.datetime "send_sms_invitation_at"
    t.boolean  "any_invitation_sent",        :default => false
    t.boolean  "delayed_sms_resend",         :default => false
    t.datetime "bounced_at"
    t.string   "bounce_status"
    t.string   "bounce_reason"
    t.datetime "cancellation_sms_sent_at"
    t.datetime "cancellation_email_sent_at"
    t.datetime "first_viewed_invitation_at"
  end

  add_index "guests", ["email", "bounced_at"], :name => "index_guests_on_email_and_bounced_at"
  add_index "guests", ["event_id", "bounced_at"], :name => "index_guests_on_event_id_and_bounced_at"

  create_table "guests_messages", :force => true do |t|
    t.integer  "event_id"
    t.string   "subject"
    t.string   "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "filter"
  end

  add_index "guests_messages", ["event_id"], :name => "index_guests_messages_on_event_id"

  create_table "hosts", :force => true do |t|
    t.integer  "event_id"
    t.string   "name",       :null => false
    t.string   "email",      :null => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "garden_id"
  end

  add_index "hosts", ["email"], :name => "index_hosts_on_email"
  add_index "hosts", ["event_id"], :name => "index_hosts_on_event_id"
  add_index "hosts", ["user_id"], :name => "index_hosts_on_user_id"

  create_table "landing_pages", :force => true do |t|
    t.integer  "category_id"
    t.string   "language"
    t.string   "friendly_url"
    t.string   "h1"
    t.string   "h2"
    t.string   "item1_header"
    t.string   "item1_body"
    t.string   "item2_header"
    t.string   "item2_body"
    t.string   "item3_header"
    t.string   "item3_body"
    t.string   "quote"
    t.string   "quoted_name"
    t.string   "quoted_city"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "quoted_file_name"
    t.string   "quoted_content_type"
    t.integer  "quoted_file_size"
    t.datetime "quoted_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "meta_description"
    t.string   "meta_keywords"
  end

  create_table "links_pages", :force => true do |t|
    t.string   "language"
    t.string   "friendly_url"
    t.text     "page_html"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "movies", :force => true do |t|
    t.integer  "event_id"
    t.integer  "embedding_provider_id"
    t.string   "in_site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "netpay_logs", :force => true do |t|
    t.string   "replyCode",          :limit => 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "replyDesc"
    t.string   "trans_id"
    t.datetime "trans_date"
    t.integer  "trans_amount",       :limit => 255, :precision => 255, :scale => 0
    t.string   "trans_currency"
    t.integer  "trans_installments"
    t.string   "trans_refNum"
    t.string   "client_id",          :limit => 10
    t.string   "paymentDisplay"
    t.string   "client_fullName"
    t.string   "client_phoneNum"
  end

  create_table "payments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.integer  "amount"
    t.integer  "emails_plan"
    t.integer  "sms_plan"
    t.integer  "prints_plan"
    t.string   "transaction_id"
    t.datetime "paid_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "emails_plan_prev"
    t.integer  "sms_plan_prev"
    t.integer  "prints_plan_prev"
    t.integer  "pay_sms"
    t.integer  "pay_emails"
    t.integer  "pay_prints"
    t.boolean  "is_agreed_to_terms", :default => false
  end

  add_index "payments", ["event_id"], :name => "index_payments_on_event_id"
  add_index "payments", ["user_id"], :name => "index_payments_on_user_id"

  create_table "reminder_logs", :force => true do |t|
    t.integer  "reminder_id"
    t.integer  "guest_id"
    t.string   "destination"
    t.string   "message"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kind",        :limit => 8
  end

  create_table "reminders", :force => true do |t|
    t.integer  "event_id"
    t.boolean  "by_email"
    t.boolean  "by_sms"
    t.string   "before_units",     :default => "days"
    t.integer  "before_value"
    t.datetime "send_reminder_at"
    t.datetime "reminder_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active",        :default => true
  end

  add_index "reminders", ["event_id"], :name => "index_reminders_on_event_id"
  add_index "reminders", ["send_reminder_at", "reminder_sent_at", "is_active"], :name => "dates_and_activity"

  create_table "sms_messages", :force => true do |t|
    t.integer  "guest_id"
    t.integer  "event_id"
    t.string   "kind",            :limit => 10
    t.string   "sender_mobile"
    t.string   "receiver_mobile"
    t.string   "message"
    t.string   "request_dump",    :limit => 2048
    t.string   "response_dump",   :limit => 2048
    t.boolean  "success"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sms_messages", ["event_id", "guest_id"], :name => "index_sms_messages_on_event_id_and_guest_id"
  add_index "sms_messages", ["sent_at"], :name => "index_sms_messages_on_sent_at"

  create_table "takings", :force => true do |t|
    t.integer  "guest_id"
    t.integer  "event_id"
    t.integer  "thing_id"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "takings", ["guest_id", "thing_id"], :name => "index_takings_on_guest_id_and_thing_id"

  create_table "things", :force => true do |t|
    t.integer  "event_id"
    t.string   "name"
    t.integer  "amount"
    t.integer  "amount_picked", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "things", ["event_id"], :name => "index_things_on_event_id"

  create_table "translation_keys", :force => true do |t|
    t.string   "key",        :limit => 1024, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "translation_keys", ["key"], :name => "index_translation_keys_on_key"

  create_table "translation_texts", :force => true do |t|
    t.text     "text"
    t.string   "locale",             :limit => 16
    t.integer  "translation_key_id",               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "translation_texts", ["translation_key_id", "locale"], :name => "index_translation_texts_on_translation_key_id_and_locale", :unique => true

  create_table "uploaded_maps", :force => true do |t|
    t.string   "map_file_name"
    t.string   "map_content_type"
    t.integer  "map_file_size"
    t.datetime "map_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "uploaded_pictures", :force => true do |t|
    t.integer  "event_id"
    t.string   "pic_file_name"
    t.string   "pic_content_type"
    t.integer  "pic_file_size"
    t.datetime "pic_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name",                :limit => 48
    t.string   "email",               :limit => 100,                    :null => false
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
    t.boolean  "is_free",                            :default => false
    t.boolean  "is_super_admin",                     :default => false
    t.boolean  "is_agreed_to_terms"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"
  add_index "users", ["single_access_token"], :name => "index_users_on_single_access_token"

  create_table "windows", :force => true do |t|
    t.integer  "design_id"
    t.integer  "top_x"
    t.integer  "top_y"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "windows", ["design_id"], :name => "index_windows_on_design_id"

end
