module Translator
  class CallableString

    attr_reader :evalable_string

    def initialize(namespace, string)
      @evalable_string = namespace.nil? ? string : "#{namespace}::#{string}"
    end

    def call
      begin
        eval evalable_string
      rescue
        raise StringNotEvalableError.new evalable_string
      end
    end

  end

  class StringNotEvalableError < ::StandardError
    def initialize(string)
      super("\"#{string}\" string can't be eval'd.")
    end
  end

end