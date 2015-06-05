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

    attr_reader :name, :service, :local, :remote

    def initialize(name, service, options = {})
      @name, @service = name, service
      @local, @remote = options.values_at(:local, :remote)
    end

    # Builds the string for eval, calling local endpoints.
    #
    # @return [String] the callable
    #
    # @since 0.1.0

    def local_callable
      @local_callable ||= service.local.nil? ? local : "#{service.local}::#{local}"
    end

    # Builds the string url for the http request.
    #
    # @return [String] the callable
    #
    # @since 0.1.0

    def remote_callable
      @remote_callable ||= service.remote.nil? ? remote : "#{service.remote}/#{remote}".gsub(/([^:])\/\//, '\1/')
    end

    # The method that perform the action independently of the endpoint_type.
    #
    # @return [Unknown] This will dynamically return whatever the eval returns
    #
    # @since 0.1.0

    def call(endpoint_type = nil)
      # TODO: Needs to figure out whether it should call remote or local
      begin
        eval "call_#{endpoint_type.to_s}"
      rescue NameError
        call_local
      end
    end

    private

    # @return [Unknown] This will dynamically return whatever the eval returns
    #
    # @since 0.1.0

    def call_local
      eval local_callable
    end

    # @return [Unknown] This will dynamically return whatever the eval returns
    #
    # @since 0.1.0

    def call_remote
      # TODO: What does it mean to call remote? Http is the answer...
    end

  end
end