# frozen_string_literal: true

module Sisjwt
  module Rails
    # Authenticates {Sisjwt} tokens, and verifies that they have the correct
    # issuer and audience.
    class Authenticator
      attr_reader :allowed_aud, :allowed_iss, :logger

      def initialize(allowed_aud, allowed_iss, logger: ::Rails.logger)
        @allowed_aud = allowed_aud.to_s
        @allowed_iss = allowed_iss.to_s
        @logger = logger
      end

      # Like {#verify}, but in the event of an error, yields a Hash describing
      # those errors.
      # @yieldparam errors [Hash]
      # @return [VerificationResult]
      def verify_or_yield_errors(token)
        verify(token).tap do |result|
          yield error_json(result) unless result.valid?
        end
      end

      # @return [VerificationResult]
      def verify(token)
        sis_jwt.verify(token).tap { |result| add_allowed(result) }
      end

      def options
        @options ||= SisJwtOptions.defaults(mode: :verify)
                                  .tap { |opts| opts.iss = allowed_iss }
      end

      private

      def sis_jwt
        @sis_jwt ||= SisJwt.new(options, logger: logger)
      end

      def add_allowed(verification_result)
        verification_result.add_allowed_aud(allowed_aud)
        verification_result.add_allowed_iss(allowed_iss)
      end

      def error_json(result)
        { errors: result.errors.full_messages }.tap do |resp|
          next unless ::Rails.env.development?

          resp[:development_context] = { verification_result: result.to_h }
        end
      end
    end
  end
end
