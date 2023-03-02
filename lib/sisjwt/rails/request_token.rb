# frozen_string_literal: true

module Sisjwt
  module Rails
    # Extracts the token from an HTTP request.
    class RequestToken
      TOKEN_PATTERN = /^Bearer ([^ ]+)$/.freeze

      attr_reader :request

      # @param request [ActionDispatch::Request]
      def initialize(request)
        @request = request
      end

      # @return [String] There bearer token from the {#request} +Authorization+
      #   header.
      # @raises [TokenMissingError] If the request doesn't contain a token.
      def token!
        token || raise_missing!
      end

      # @return [String,nil] There bearer token from the {#request}
      #   +Authorization+ header, if there is one.
      def token
        @token ||= authorization_header[TOKEN_PATTERN, 1]
      end

      private

      def authorization_header
        request.headers.fetch('Authorization', '')
      end

      def raise_missing!
        raise TokenMissingError,
              'SISJWT token not set correctly for authentication'
      end
    end
  end
end
