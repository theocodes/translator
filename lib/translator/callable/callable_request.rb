require 'byebug'
require 'rest-client'

module Translator
  class CallableRequest

    # Implements a generic version of a (remote) callable object.
    #
    # @param base_url [String] to be used for composing the url to call
    # @param options[:path] [String] the last part of the url
    # @param options[:verb] [Symbol] HTTP verb to determine type of request
    #
    # @since 0.1.0

    attr_reader :base_url, :full_raw_url, :path, :verb
    attr_accessor :params, :body

    def initialize(base_url, options)
      @base_url = base_url
      @verb, @path = options.values_at(:verb, :path)
      @full_raw_url = "#{base_url}#{@path}".gsub(/([^:])\/\//, '\1/').freeze
    end

    # Makes the http call and returns the response
    #
    # @param [Hash] params to be sent with request
    #
    # @since 0.1.0

    def call(params)
      url = process_url(params)
      case verb
      when :post
        RestClient.post(url, :data => params)
      when :get
        RestClient.get(url)
      when :update
        RestClient.put(url, :data => params)
      when :delete
        RestClient.delete(url)
      end
    end

    # Used only to get the processed url ahead of time. (Specially used for testing)
    # Will replace placeholders in the url (Eg http://site.com/:id) with values present in params (if any)
    #
    # @params [Hash] data to be used for placeholder replacements
    #
    # @since 0.1.0

    def processed_url(params)
      @processed_url ||= process_url(params)
    end

    private

    # Gets a list of placeholder keys in the url
    #
    # @since 0.1.0

    def get_params
      full_raw_url.scan(/(:\w+)/).map {|k| k[0].gsub(":", "").to_sym }
    end

    # @see Translator::CallableRequest#processed_url
    #
    # @since 0.1.0

    def process_url(params)
      processed_string = full_raw_url.dup
      params.each do |key, _val|
        processed_string.gsub!(":#{key.to_s}", "#{params[key]}")
      end
      processed_string
    end

  end

end
