require 'translator/callable'
require 'translator/callable_request'

module Translator
  class RemoteCallable < Callable

    attr_reader :base_url, :callable_subject

    def initialize(base_url, arg)
      @base_url = base_url
      case arg
      when String
        # assumes get (for convenience)
        @callable_subject = Translator::CallableRequest.new(base_url, { verb: :get, path: arg })
      when Hash
        @callable_subject = Translator::CallableRequest.new(base_url, arg)
      else
        raise CallableTypeError.new(self, arg)
      end
    end

  end
end
