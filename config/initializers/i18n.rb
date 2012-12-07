#include FastGettext::TranslationRepository::Db.require_models

AVAILABLE_LOCALES = FastGettext.available_locales = ['en','he', 'ru']
AVAILABLE_LOCALE_NAMES = {'en' => "English", 'he' => "עברית", 'ru' => "Русский"}
#FastGettext.add_text_domain 'app', :type => :db, :model => TranslationKey
#FastGettext.default_text_domain = 'app'
#FastGettext::TranslationRepository::Db.preload unless $0 =~ /rake/

module ActionView
  module Helpers
    class DateTimeSelector
      def build_selects_from_types_with_locale(order)
        if "he" == current_controller.send(:current_locale)
          build_selects_from_types_without_locale(order.reverse)
        else
          build_selects_from_types_without_locale(order)
        end
      end
      alias_method_chain :build_selects_from_types, :locale
    end
  end
end
