module ShopifyAPI
  module Pollable
    ACCEPTED_RESPONSE_CODE = "202"
    INTERVAL_HEADER = "Retry-After"
    LOCATION_HEADER = "Location"

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      attr_writer :max_retries

      def max_retries
        @max_retries ||= 35
      end

      attr_writer :interval

      def interval
        @interval ||= default_interval
      end

      private

      def default_interval
        connection.response.headers[INTERVAL_HEADER] || 500
      end

      def poll_location_url
        connection.response.headers[LOCATION_HEADER]
      end

      def keep_polling?(n)
        [
          connection.response.code == ACCEPTED_RESPONSE_CODE,
          n <= max_retries,
        ].any?
      end

      def poll
        retry_n = 1
        result = nil

        loop do
          result = yield
          break unless keep_polling?

          retry_n += 1
          sleep(interval)
        end

        result
      end
    end
  end
end
