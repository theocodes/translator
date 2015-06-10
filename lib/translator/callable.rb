require 'translator/callable_string'

module Translator
  class Callable

    def call(data)
      raise "Must implement call(data)"
    end

  end

  class CallableTypeError < ::StandardError
    def initialize(klass, value)
      super("#{value.class} is not a supported value for #{klass.class}")
    end
  end

end
