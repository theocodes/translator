module Translator
  class CallableObject

    # This implements a generic version of a (local) callable object.
    #
    # @param namespace [String] Used for composing the constant to act upon
    # @param options[:object] Object to to act upon
    # @param options[:method] Method to call
    #
    # @since 0.1.0

    attr_reader :object, :method, :constant

    def initialize(namespace, options)
      @constant = constantize(namespace, options[:object])
      @method = options[:method].to_sym
      @object = initializer(@constant)
    end

    # The method that invokes the endpoint
    #
    # @param data [Hash] to be passed into endpoint
    #
    # @since 0.1.0

    def call(data)
      object.send(method, data)
    end

    private

    def constantize(namespace, obj)
      Object.const_get(namespace ? "#{namespace}::#{obj}" : obj)
    end

    # Returns the object to act upon. First checks whether the class responds to
    # the method instance var (class mathod) otherwise instantiates an object based on constant
    #
    # @param constant [Constant] to be sent the message
    #
    # @since 0.1.0

    def initializer(constant)
      if constant.respond_to? method
        constant
      else
        constant.new
      end
    end

  end
end
