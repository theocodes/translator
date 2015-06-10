require 'byebug'
require 'rest-client'

module Translator
  class CallableRequest

    attr_reader :base_url, :full_raw_url, :path, :verb
    attr_accessor :params, :body

    def initialize(base_url, options)
      @base_url = base_url
      @verb, @path = options.values_at(:verb, :path)
      @full_raw_url = "#{base_url}#{@path}".gsub(/([^:])\/\//, '\1/').freeze
    end

    def call(params)
      url = process_url(params)
      case verb
      when :post
        RestClient.post(url, :data => params)
      when :get
        RestClient.get(url)
      when :update
      when :delete
      end
    end

    # Used only to get the processed url ahead of time.
    # Specially useful on testing
    def processed_url(params)
      @processed_url ||= process_url(params)
    end

    private

    def get_params
      full_raw_url.scan(/(:\w+)/).map {|k| k[0].gsub(":", "").to_sym }
    end

    def process_url(params)
      processed_string = full_raw_url.dup
      params.each do |key, _val|
        processed_string.gsub!(":#{key.to_s}", "#{params[key]}")
      end
      processed_string
    end

  end

end
