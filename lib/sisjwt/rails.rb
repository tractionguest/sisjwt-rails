# frozen_string_literal: true

require 'rails'
require 'sisjwt'
require_relative './rails/authenticator'
require_relative './rails/request_token'
require_relative './rails/verification'
require_relative './rails/version'

module Sisjwt
  # Rails controller integration for the {Sisjwt} rubygem.
  module Rails
    Error = Class.new(StandardError)
    TokenMissingError = Class.new(Error)

    class << self
      # The Sisjwt configuration for every configured Rails controller.
      # @return [Hash<Class, Hash<Symbol, Hash>>]
      def configuration
        @configuration ||= Hash.new do |cfg, klass|
          cfg[klass] = Hash.new { |h, attr| h[attr] = {} }
        end
      end
    end
  end
end
