include FastGettext::TranslationRepository::Db.require_models

AVAILABLE_LOCALES = FastGettext.available_locales = ['en','he', 'ru']
AVAILABLE_LOCALE_NAMES = {'en' => "English", 'he' => "עברית", 'ru' => "Русский"}
FastGettext.add_text_domain 'app', :type => :db, :model => TranslationKey
FastGettext.default_text_domain = 'app'
FastGettext::TranslationRepository::Db.preload unless $0 =~ /rake/