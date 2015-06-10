require 'byebug'
require 'rest-client'

module Translator
  class LocalCallable

    attr_reader :base_url, :full_raw_url, :path, :verb
    attr_accessor :params, :body

    def initialize(base_url, hash)
      @base_url = base_url
      @verb, @path, @url_params, @params= hash.values_at(:verb, :path, :url_params, :params)
      @full_raw_url = "#{base_url}#{@path}".gsub(/([^:])\/\//, '\1/').freeze
    end

    def call(url_params: {}, params: {})
      url = process_url(url_params)
      case verb
      when :post
        RestClient.post(url, :nested => params)
      when :get
        RestClient.get(url)
      when :update
      when :delete
      end
    end

    # Used only to get the processed url ahead of time.
    # Specially useful on testing
    def processed_url(url_params: {}, params: {})
      @processed_url ||= process_url(url_params)
    end

    private

    def get_params
      full_raw_url.scan(/(:\w+)/).map {|k| k[0].gsub(":", "").to_sym }
    end

    def process_url(params_hash)
      processed_string = full_raw_url.dup
      params_hash.each do |key, _val|
        raise UnknownParamError.new(self, key) unless get_params.include?(key)
        processed_string.gsub!(":#{key.to_s}", "#{params_hash[key]}")
      end
      processed_string
    end

  end

  class UnknownParamError < ::StandardError
    def initialize(klass, value)
      super("Param must be declared in URL. Passing without first declaring is prohibited.")
    end
  end

end
