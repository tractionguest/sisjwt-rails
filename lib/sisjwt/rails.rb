# frozen_string_literal: true

require_relative "version"
require "active_support/concern"

module Sisjwt
  class SisjwtError < StandardError; end
  module Verification
    extend ActiveSupport::Concern

    included do
      before_action :extract_token
      before_action :authenticate_sisjwt

      def extract_token
        @token = request.headers['Authorization'][/^Bearer ([^ ]+)$/, 1]

        if @token.blank?
          head :forbidden
          return
        end
      end

      def authenticate_sisjwt
        sisjwt = ::Sisjwt::SisJwt.new(sisjwt_options, logger: Rails.logger)
        @sis_jwt_token = sisjwt.verify(@token)
      rescue StandardError => e
        Rails.logger.error("[SISJWT-authenticate_sisjwt]: #{e}")
        head :forbidden
      end

      def sisjwt_options
        return @sisjwt_options if @sisjwt_options.present?

        @sisjwt_options = ::Sisjwt::SisJwtOptions.defaults(mode: :verify).tap do |opts|
          opts.iss = @@allowed_iss
        end
      end
    end

    class_methods do
      def sisjwt_iss(allowed_iss)
        @@allowed_iss = allowed_iss
      end
    end
  end
end
