# frozen_string_literal: true

require_relative "version"
require "active_support/concern"

module SisjwtRails
  class SisjwtError < StandardError; end
  module Verification
    extend ActiveSupport::Concern

    included do
      # before_action :extract_token
      before_action :authenticate_sisjwt

      def authenticate_sisjwt
        token = extract_token!
        raise "SISJWT token not set correctly for authentication" unless token.is_a?(String)

        sisjwt = ::Sisjwt::SisJwt.new(sisjwt_options, logger: Rails.logger)
        @sisjwt_token = sisjwt.verify(token)
        verify_sisjwt!
      # rescue JWT::DecodeError => e
      #   # We can rescue from this error and return a result
      #   Rails.logger.error("[SISJWT-authenticate_sisjwt]: [#{e.class}]#{e}")
      #   @sisjwt_token = ::Sisjwt::VerificationResult.new(nil, nil, e)
      rescue StandardError => e
        raise
        Rails.logger.error("[SISJWT-authenticate_sisjwt]: [#{e.class}]#{e}")
        head :forbidden
      end

      def sisjwt_options
        return @sisjwt_options if @sisjwt_options.present?

        @sisjwt_options = ::Sisjwt::SisJwtOptions.defaults(mode: :verify).tap do |opts|
          opts.iss = @@allowed_iss
        end
      end

      private

      # Extracts and returns the JWT from authorization/bearer header
      # Issues a forbidden respose and nil return if it could not extract
      def extract_token!
        sisjwt_token = request.headers['Authorization'][/^Bearer ([^ ]+)$/, 1]

        if sisjwt_token.blank?
          head :forbidden
          return
        end

        sisjwt_token
      end

      def verify_sisjwt!
        # Sanity check
        if @sisjwt_token.blank?
          head :forbidden
          raise "SISJWT is somehow blank!?"
        end

        @sisjwt_token.add_allowed_aud(@@allowed_aud.to_s)
        @sisjwt_token.add_allowed_iss(@@allowed_iss.to_s)

        unless @sisjwt_token.valid?
          Rails.logger.error("[SISJWT-authenticate_sisjwt][#{controller_path}##{action_name}]: token is not valid: #{@sisjwt_token.errors.full_messages}")
          resp = {
            errors: @sisjwt_token.errors.full_messages,
            development_context: Rails.env.development? ? {} : nil,
          }.compact
          if Rails.env.development?
            resp[:development_context][:verification_result] = @sisjwt_token.to_h
          end
          render(json: resp, status: :forbidden)
        end
      end
    end

    class_methods do
      def sisjwt_aud(allowed_aud)
        @@allowed_aud = allowed_aud
      end

      def sisjwt_iss(allowed_iss)
        @@allowed_iss = allowed_iss
      end
    end
  end
end
