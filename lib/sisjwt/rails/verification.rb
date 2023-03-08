# frozen_string_literal: true

require 'active_support/concern'

module Sisjwt
  module Rails
    # A Rails {ActiveSupport::Concern} for Rails controllers that wish to
    # authenticate their endpoints with {Sisjwt} tokens.
    #
    # @example
    #   class IncomingFromSicController < ApplicationController
    #     include Sisjwt::Rails::Verification
    #
    #     sisjwt_iss :sic
    #     sisjwt_aud :sie
    #
    #     skip_before_action :authenticate_current_user
    #     skip_before_action :authenticate_sisjwt, only: :unauthenticated_endpoint
    #
    #     def authenticated_endpoint
    #       # ...
    #     end
    #
    #     def unauthenticated_endpoint
    #       # ...
    #     end
    #   end
    module Verification
      extend ActiveSupport::Concern

      included do
        prepend_before_action :authenticate_sisjwt

        # Authenticates the current HTTP request via the SISJWT in its
        # +Authorization+ header.
        def authenticate_sisjwt
          token = RequestToken.new(request).token!

          sisjwt_authenticator.verify_or_yield_errors(token) do |json|
            log_sisjwt_errors(json[:errors])
            render(json: json, status: :forbidden)
          end
        rescue StandardError => e
          ::Rails.logger.error("[SISJWT-authenticate_sisjwt]: [#{e.class}] #{e}")
          head :forbidden
          raise
        end

        def sisjwt_create_token(payload)
          signing_options = ::Sisjwt::SisJwtOptions.defaults(mode: :sign).tap do |opts|
            # We are signing a return request so iss/aud is flipped from how it
            # is specififed in the controller
            opts.iss = @@allowed_aud
            opts.aud = @@allowed_iss
          end

          sisjwt = ::Sisjwt::SisJwt.new(signing_options, logger: logger)
          sisjwt.encode(payload)
        end

        protected

        def sisjwt_authenticator
          cfg = self.class.sisjwt_config
          @sisjwt_authenticator ||= Authenticator.new(cfg[:allowed_aud],
                                                      cfg[:allowed_iss])
        end

        def sisjwt_options
          sisjwt_authenticator.options
        end

        private

        def log_sisjwt_errors(errors)
          ::Rails.logger.error("[SISJWT-authenticate_sisjwt][#{controller_path}##{action_name}]: " \
                               "token is not valid: #{errors}")
        end
      end

      class_methods do
        # @return The {Sisjwt::Rails} configuration for this controller.
        def sisjwt_config
          Sisjwt::Rails.configuration[self]
        end

        # @param allowed_aud [#to_s] The allowed audience of tokens used by this
        #   controller.
        def sisjwt_aud(allowed_aud)
          sisjwt_config[:allowed_aud] = allowed_aud
        end

        # @param allowed_iss [#to_s] The allowed issuer of tokens used by this
        #   controller.
        def sisjwt_iss(allowed_iss)
          sisjwt_config[:allowed_iss] = allowed_iss
        end
      end
    end
  end
end
