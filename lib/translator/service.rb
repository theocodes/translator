require 'translator/endpoint'

module Translator
  class Service

    # A Service encapsulates endpoints.
    #
    # @param name [Symbol] service name
    # @param options [Hash]
    #   @option options[:namespace] [String] namespace to be used for local calls
    #   @option options[:base_url] [String] base url to be used for requests
    #
    # @since 0.1.0

    attr_reader :name, :namespace, :base_url

    def initialize(name, options = {})
      @name = name
      @namespace, @base_url = options.values_at(:namespace, :base_url)
    end

    # Gets the registered endpoints.
    #
    # @return [Array<Translator::Endpoint>]
    # @see Translator::Endpoint
    #
    # @since 0.1.0

    def endpoints
      @endpoints ||= []
    end

    # Public interface for registering endpoints.
    #
    # @param name [Symbol] service name
    # @param local [Hash] a hash containing config options for local calls (object, method)
    # @param remote [Hash] a hash containing config options for remote request (path, verb)
    #
    #   translator = Translator.configure do
    #     service :auth, namespace: 'Authentication', base_url: 'http://securesite.com/auth' do
    #       endpoint :login, local: { object: 'Login', method: 'attempt' }, remote: { path: '/login', verb: :post }
    #     end
    #   end
    #
    #   Authentication::Login.attempt(params) # For local
    #   http://securesite.com/auth/login # For remote
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
    # The arguments passed to that method may vary depending on the intention.
    # @see Translator::Callable
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
    #       endpoint :some_endpoint, local: { object: 'SomeEndpoint', method: 'run' } ...
    #     end
    #   end
    #
    #   Calling the endpoint without arguments returns the endpoint itself.
    #   Eg: translator.some_api.some_endpoint #=> [Translator::Endpoint]
    #
    #   Calling the endpoint with arguments will call the 'callable' method in the endpoint
    #   Note: This will use the deploy configuration to determine whether that call should be local or remote
    #   Eg: translator.some_api.some_endpoint({ id: 1, role: 'admin'}) #=> Same as calling SomeEndpoint.new.run({ id: 1, role: 'admin'})
    #
    #   Additionally, if we wanted force it to call 'local', we would do as follows:
    #   Eg: translator.some_api.some_endpoint.local({ id: 1, role: 'admin'}) #=> Same as above, but will bypass deploy config
    #

    def register_method(endpoint)
      self.define_singleton_method(endpoint.name) do |*args|
        endpoint.call(args)
      end
    end

  end
end
