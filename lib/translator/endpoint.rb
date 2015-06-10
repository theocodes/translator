require 'translator/local_callable'
require 'translator/remote_callable'

module Translator
  class Endpoint

    # An Endpoint is responsible for local and remote actions.
    #
    # @param name [Symbol] the endpoint name
    # @param service [Translator::Service] the parent service

    # @param options [Hash]
    # @option options [String] :local Endpoint local address
    # @option options [String] :remote Endpoint remote address
    #
    # @since 0.1.0

    attr_reader :name, :service, :local_callable, :remote_callable

    def initialize(name, service, options = {})
      @name, @service = name, service
      @local_callable = LocalCallable.new service.namespace, options.values_at(:local).first
      @remote_callable = RemoteCallable.new service.base_url, options.values_at(:remote).first
    end

    # Builds the string for eval, calling local endpoints.
    #
    # @return [String] the callable
    #
    # @since 0.1.0

    # def local_callable
    #
    #
    #   # if local.is_a? String
    #   #   @local_callable ||= service.namespace.nil? ? local : "#{service.namespace}::#{local}"
    #   # elsif local.is_a? Proc
    #   #
    #   # end
    # end

    def remote
      remote_callable.callable_subject
    end

    def local
      local_callable
    end

    # The method that perform the action independently of the endpoint_type.
    #
    # @return [Unknown] This will dynamically return whatever the eval returns
    #
    # @since 0.1.0

    def call(args)
      if args.empty?
        self
      else
        # TODO: Add logic for dynamically calling local/remote based on deploy config
        local_callable.call(args[0])
      end
    end

  end
end
