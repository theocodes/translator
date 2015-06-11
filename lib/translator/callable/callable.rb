module Translator
  class Callable

    # Callable wraps a 'callable object'
    #
    # @param namespace [String] a namespace for a given endpoint
    # @param options [Hash] options to be passed to a callable object
    #
    # @see Translator::CallableObject
    # @see Translator::CallableRequest
    #
    # @since 0.1.0

    attr_reader :callable_object

    def initialize(namespace, options, callable)
      raise Translator::CallableTypeError.new self, options unless options.is_a? Hash
      begin
        @callable_object = callable.new namespace, options
      rescue ArgumentError
        raise CallableArgumentMissingError.new self
      end
    end

    # Callables must implement call to be considered valid
    #
    # @param data [Hash] hash to be passed to endpoint
    #
    # @since 0.1.0

    def calls(data)
      raise "Must implement call(data)"
    end

  end

  # @since 0.1.0

  class CallableArgumentMissingError < ::StandardError
    def initialize(klass)
      super("#{klass.class} initialize must accept 2 arguments (namespace, params)")
    end
  end

  class CallableTypeError < ::StandardError
    def initialize(klass, value)
      super("#{value.class} is not a supported value for #{klass.class}. Hash only!")
    end
  end

end
