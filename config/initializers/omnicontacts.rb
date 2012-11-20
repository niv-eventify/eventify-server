require "omnicontacts"
require "omnicontacts/middleware/base_oauth"

ActionController::Dispatcher.middleware.use OmniContacts::Builder do
  importer :gmail, GMAIL_CLIENT_ID, GMAIL_CLIENT_SECRET
#  importer :yahoo, "consumer_id", "consumer_secret", {:callback_path => '/callback'}
#  importer :hotmail, "client_id", "client_secret"
end
