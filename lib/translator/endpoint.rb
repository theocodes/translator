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

    # Builds the string url for the http request.
    #
    # @return [String] the callable
    #
    # @since 0.1.0

    # def remote_callable
    #   @remote_callable ||= service.base_url.nil? ? remote : "#{service.base_url}#{remote}".gsub(/([^:])\/\//, '\1/')
    # end

    # The method that perform the action independently of the endpoint_type.
    #
    # @return [Unknown] This will dynamically return whatever the eval returns
    #
    # @since 0.1.0

    def call(endpoint_type = nil)
      # TODO: Needs to figure out whether it should call remote or local
      begin
        instance_eval "call_#{endpoint_type.to_s}"
      rescue NameError
        call_local
      end
    end

    private

    # @return [Unknown] This will dynamically return whatever the eval returns
    #
    # @since 0.1.0

    def call_local
      local_callable.call
    end

    # @return [Unknown] This will dynamically return whatever the eval returns
    #
    # @since 0.1.0

    def call_remote
      remote_callable.call
    end

  end
end
