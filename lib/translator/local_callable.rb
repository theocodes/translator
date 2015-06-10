require 'translator/callable'
require 'translator/callable_string'
require 'byebug'

module Translator
  class LocalCallable < Callable

    attr_reader :object, :method, :constant

    def initialize(namespace, options)
      @constant = constantize(namespace, options[:object])
      @method = options[:method].to_sym
      @object = initializer(@constant)
    end

    def call(data)
      object.send(method, data)
    end

    private

    def constantize(namespace, obj)
      Object.const_get(namespace ? "#{namespace}::#{obj}" : obj)
    end

    def initializer(constant)
      if constant.respond_to? method
        constant
      else
        constant.new
      end
    end

  end
end
