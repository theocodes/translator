require 'translator/callable/callable_object'
require 'translator/callable/callable_request'

module Translator
  class Endpoint

    # An Endpoint is responsible for local and remote actions.
    #
    # @param name [Symbol] the endpoint name
    # @param service [Translator::Service] the service in which the endpoint belongs
    # @param options [Hash]
    #   @option options[:local] [Hash] options for local configuration (object, method, callable_object)
    #   @option options[:remote] [Hash] options for remote configuration (path, verb, callable_object)
    #
    # @since 0.1.0

    attr_reader :name, :service, :local_callable, :remote_callable

    def initialize(name, service, options = {})
      @name, @service = name, service
      begin
        @local_callable = Callable.new service.namespace, options[:local], Translator::CallableObject
      rescue NameError
        @local_callable = NonLocalCallable.new options[:local]
      end
      @remote_callable = Callable.new service.base_url, options[:remote], Translator::CallableRequest
    end


    def constantize(namespace, obj)
      Object.const_get(namespace ? "#{namespace}::#{obj}" : obj)
    end

    # This bypasses deploy config and calls the 'remote' version of the endpoint (http)
    # passing args to it.
    #
    # OR
    #
    # When called without args, will return the remote [Translator::CallableRequest]
    #
    # @param args [Hash] args to be passed into the endpoint
    #
    # @since 0.1.0

    def remote(*args)
      if args.empty?
        remote_callable.callable_object
      else
        remote_callable.callable_object.call(args[0])
      end
    end

    # This bypasses deploy config and calls the 'local' version of the endpoint
    # passing args to it.
    #
    # OR
    #
    # When called without args, will return the remote [Translator::CallableObject]
    #
    # @param args [Hash] args to be passed into the endpoint
    #
    # @since 0.1.0

    def local(*args)
      if args.empty?
        local_callable.callable_object
      else
        local_callable.callable_object.call(args[0])
      end
    end

    # Called internally when endpoint is called with arguments
    #
    # @return [Unknown] This will dynamically return whatever the endpoint returns
    #
    # @since 0.1.0

    def call(args)
      if args.empty?
        self
      else
        # TODO: Add logic for dynamically calling local/remote based on deploy config
        raise "Is it local? Is it remote? Who is to say?!"
        local_callable.call(args[0])
      end
    end

  end

  class NonLocalCallable

    attr_reader :method, :object

    def initialize(options)
      @object, @method = options.values_at(:object, :method)
    end

    def call(data)
      raise "Endpoint isn't local!"
    end

    def callable_object
      self
    end
  end


end
