require_relative "utils/utils"
require "translator/configuration"

module Translator

  include Translator::Utils::ClassAttribute

  class_attribute :configuration
  self.configuration = Configuration.new

  # Configure the adapter.
  # It yields the given block in the context of the configuration
  #
  # @param blk [Proc] the configuration block
  #
  # @since 0.1.0
  #
  # @see Translator::Configuration
  #
  # @example
  #   require 'translator'
  #
  #   Translator.configure do
  #     service :some_api do
  #       endpoint :name, local: { object: 'ObjectName', method: :method_name }, remote: { path: 'path/:param', verb: :http_verb }
  #     end
  #   end

  def self.configure(&blk)
    configuration.instance_eval(&blk)
    self.configuration
  end

end
