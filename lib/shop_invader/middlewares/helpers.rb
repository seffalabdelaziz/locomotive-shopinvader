module Locomotive::Steam
  module Middlewares

    module Helpers

      alias_method :orig_render_response, :render_response
      alias_method :orig_inject_cookies, :inject_cookies

      def render_response(content, code = 200, type = nil)
        status, headers, body = orig_render_response(content, code, type)
        if status == 200
          set_200_header(headers)
        end
        @next_response = [status, headers, body]
      end

      private

      def set_200_header(headers)
        if env['steam.cache_control']
          headers['Cache-Control'] = env['steam.cache_control']
        else
          headers['Cache-Control'] = "max-age=0, private, must-revalidate"
        end
        if env['steam.cache_vary']
          headers['Vary'] = env['steam.cache_vary'].join(",")
        end
      end

      def inject_cookies(headers)
        role = customer && customer.role || default_role
        # TODO make the max_age configurable maybe we should use the same age as the main cookie
        request.env['steam.cookies']['role'] = {value: role, path: '/', max_age: 1.year}
        orig_inject_cookies(headers)
      end

      def customer
        @customer ||= request.env['authenticated_entry']
      end

      def default_role
        @default_role ||= site.metafields['erp']['default_role']
      end
    end
  end
end
