require 'translator/endpoint'

module Translator
  class Service

    # A Service encapsulates endpoints.
    #
    # @param name [Symbol] service name
    #
    # @param options [Hash]
    # @option options [String] :local namespace for local
    # @option options [String] :remote namespace for remote
    #
    # @since 0.1.0

    attr_reader :name, :local, :remote

    def initialize(name, options = {})
      @name = name
      @local, @remote = options.values_at(:local, :remote)
    end

    # Gets the registered services.
    #
    # @return [Array<Translator::Service>]
    # @see Translator::Endpoint
    #
    # @since 0.1.0

    def endpoints
      @endpoints ||= []
    end

    # Public interface for registering an endpoint.
    #
    # @param name [Symbol] service name
    # @param local [String] a string that can be translated to a callable
    # @param remote [String] an url to be called
    #
    # @example
    #   require 'translator'
    #
    #   translator = Translator.configure do
    #     service :auth, local: 'Authentication', remote: 'http://securesite.com/auth' do
    #       endpoint :login, local: 'Login.attempt(params)', 'attempt'
    #     end
    #   end
    #
    #   Authentication::Login.attempt(params) # For local
    #   http://securesite.com/auth/attempt # For remote
    #
    # @see Translator::Endpoint
    #
    # @return [void]
    #
    # @since 0.1.0

    def endpoint(name, local: nil, remote: nil)
      register_endpoint(Translator::Endpoint.new(name, self, local: local, remote: remote))
    end

    private

    # Inserts an endpoint into endpoints.
    #
    # @param endpoint [Translator::Endpoint] an Object
    # @return [void]
    #
    # @since 0.1.0
    # @api private

    def register_endpoint(endpoint)
      endpoints << endpoint
      register_method(endpoint)
    end

    # Turns the endpoint name into a method that can be invoked.
    #
    # @param endpoint [Translator::Endpoint] an Object
    # @return [void]
    #
    # @since 0.1.0
    # @api private
    #
    # @see Translator::Endpoint
    #
    # @example
    #   require 'translator'
    #
    #   translator = Translator.configure do
    #     service :some_api do
    #       endpoint :name, local: SomeClass.new(params).run
    #     end
    #   end
    #
    #   translator.some_api.name

    def register_method(endpoint)
      self.define_singleton_method(endpoint.name) do
        endpoint
      end
    end

  end
end