module Translator
  class CallableRequest

    attr_reader :base_url, :full_url, :path, :verb
    attr_accessor :params, :body

    def initialize(base_url, hash)
      @base_url = base_url
      @verb, @path, @params, @body = hash.values_at(:verb, :path, :params, :body)
      @full_url = "#{base_url}#{@path}".gsub(/([^:])\/\//, '\1/')
    end

    def processed_url
      full_url
    end

    def call(body)
      # TODO: HTTP library must come into play.
    end

  end

end
