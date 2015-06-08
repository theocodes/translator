require 'translator/callable'
require 'translator/callable_string'

module Translator
  class LocalCallable < Callable

    attr_reader :service, :callable_subject

    def initialize(namespace, arg)
      @service = service
      case arg
        when Proc
          # Proc implements a call - Nothing to do! yay!
          @callable_subject = arg
        when String
          @callable_subject = Translator::CallableString.new(namespace, arg)
        else
          raise CallableTypeError.new(self, arg)
      end
    end

  end

end
