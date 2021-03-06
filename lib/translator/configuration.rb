require_relative 'service'

module Translator
  class Configuration

    # Public interface for registering a service.
    #
    # @param name [Symbol] service name
    # @param namespace [String] a namespace for a local callable (optional)
    # @param base_url [String] base url to be used for remote requests
    # @param blk [Proc] the configuration block
    #
    # @example
    #   require 'translator'
    #
    #   translator = Translator.configure do
    #     service :some_api, namespace: 'SomeApi', base_url: 'http://mysite.com/some-api' do
    #       endpoint :name, local: SomeClass.some_method, '/some-url'
    #     end
    #   end
    #
    #   SomeApi::SomeClass.some_method # For local
    #   http://mysite.com/some-api/some-url # For remote
    #
    # @see Translator::Service
    #
    # @return [void]
    #
    # @since 0.1.0

    def service(name, namespace: nil, base_url: nil, &blk)
      svc = Translator::Service.new(name, namespace: namespace, base_url: base_url)
      svc.instance_eval(&blk)
      register_service(svc)
    end

    # Gets the registered services.
    #
    # @return [Array<Translator::Service>]
    #
    # @since 0.1.0

    def services
      @services ||= []
    end

    private

    # Inserts a service into services and registers a singleton method.
    #
    # @param service [Translator::Service] an Object
    # @return [void]
    #
    # @since 0.1.0
    # @api private

    def register_service(service)
      services << service
      register_method(service)
    end

    # Turns the service name into a method that can be invoked.
    #
    # @param service [Translator::Service] an Object
    # @return [void]
    #
    # @since 0.1.0
    # @api private
    #
    # @see Translator::Service
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
    #   translator.some_api

    def register_method(service)
      self.define_singleton_method(service.name) do
        service
      end
    end

  end
end
