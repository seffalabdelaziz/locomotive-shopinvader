require 'locomotive/steam/middlewares'

module Locomotive::Steam
  module Middlewares

    class Locale
      alias_method :orig_extract_locale, :extract_locale

      def extract_locale
        if request.path_info.start_with?('/invader')
          env['steam.locale'] = services.locale = locale_from_cookie || default_locale
        else
          orig_extract_locale
        end
      end

    end

  end
end
