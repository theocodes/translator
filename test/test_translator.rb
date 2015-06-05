require 'minitest_helper'
require 'translator'

module SomeApi
  module InnerModule
    def self.run
      "returned value"
    end
  end
end

module SomethingElse
  def self.run
    "returned other value"
  end
end

class TestTranslator < Minitest::Test

  def setup
    @translator_one = Translator.configure do
      service :some_api, local: 'SomeApi', remote: 'http://rest-api.com' do
        endpoint :test_endpoint, local: 'InnerModule.run', remote: '/someapi/test'
      end
    end

    @translator_two = Translator.configure do
      service :some_other_api do
        endpoint :test_other_endpoint, local: 'SomethingElse.run', remote: 'http://someotherapi.com/test'
      end
    end
  end

  def test_that_it_has_a_version_number
    refute_nil ::Translator::VERSION
  end

  def test_it_responds_to_configure
    assert_respond_to Translator, :configure
  end

  def test_it_responds_to_service_method
    assert_respond_to @translator_one, :some_api
    assert_respond_to @translator_two, :some_other_api
  end

  def test_it_responds_to_endpoint_method
    assert_respond_to @translator_one.some_api, :test_endpoint
    assert_respond_to @translator_two.some_other_api, :test_other_endpoint
  end

  def test_it_builds_local_callable
    assert_equal @translator_one.some_api.test_endpoint.local_callable, 'SomeApi::InnerModule.run'
    assert_equal @translator_two.some_other_api.test_other_endpoint.local_callable, 'SomethingElse.run'
  end

  def test_it_builds_remote_callable
    assert_equal @translator_one.some_api.test_endpoint.remote_callable, 'http://rest-api.com/someapi/test'
    assert_equal @translator_two.some_other_api.test_other_endpoint.remote_callable, 'http://someotherapi.com/test'
  end

  def test_it_invokes_local
    assert_equal @translator_one.some_api.test_endpoint.call, "returned value"
    assert_equal @translator_two.some_other_api.test_other_endpoint.call, "returned other value"
  end

end
