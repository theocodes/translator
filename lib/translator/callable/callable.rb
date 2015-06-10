module Translator
  class Callable

    attr_reader :callable_object

    def initialize(namespace, options, callable)
      raise Translator::CallableTypeError.new self, options unless options.is_a? Hash
      begin
        @callable_object = callable.new namespace, options
      rescue ArgumentError
        raise CallableArgumentMissingError.new self
      end
    end

    def call(data)
      raise "Must implement call(data)"
    end

  end

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
