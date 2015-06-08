require 'minitest_helper'
require 'translator'
require 'translator/callable'
require 'translator/local_callable'
require 'translator/remote_callable'
require 'translator/callable_request'

module SomeApi
  module InnerModule
    def self.run
      "returned value"
    end
  end
end

class SomethingElse
  def run
    "returned other value"
  end
end

class TestTranslator < Minitest::Test

  def setup
    @translator_one = Translator.configure do
      service :some_api, namespace: 'SomeApi', base_url: 'http://rest-api.com/' do
        endpoint :test_endpoint, local: 'InnerModule.run', remote: { path: '/something/:id', verb: :post, params: {id: 1}}
      end
    end

    @translator_two = Translator.configure do
      service :some_other_api do
        endpoint :test_other_endpoint, local: 'SomethingElse.new.run', remote: {}
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

  def test_endpoint_returns_a_callable
    assert_kind_of Translator::LocalCallable, @translator_one.some_api.test_endpoint.local_callable
    assert_kind_of Translator::RemoteCallable, @translator_two.some_other_api.test_other_endpoint.remote_callable
  end

  def test_remote_callable_subject
    assert_kind_of Translator::CallableRequest, @translator_two.some_other_api.test_other_endpoint.remote_callable.callable_subject
    assert_equal @translator_one.some_api.test_endpoint.remote_callable.callable_subject.base_url, "http://rest-api.com/"
    assert_equal @translator_one.some_api.test_endpoint.remote_callable.callable_subject.full_url, "http://rest-api.com/something/:id"
    assert_equal @translator_one.some_api.test_endpoint.remote_callable.callable_subject.path, "/something/:id"
    assert_equal @translator_one.some_api.test_endpoint.remote_callable.callable_subject.verb, :post
    assert_equal @translator_one.some_api.test_endpoint.remote_callable.callable_subject.processed_url, "http://rest-api.com/something/1"
  end

  def test_it_takes_a_proc_for_local
    my_proc = Proc.new do
      SomeApi::InnerModule.run
    end

    my_translator = Translator.configure do
      service :some_api, base_url: 'http://rest-api.com' do
        endpoint :test_endpoint, local: my_proc, remote: {}
      end
    end
    assert_equal my_translator.some_api.test_endpoint.call, "returned value"
  end

  def test_it_takes_string_for_local
    assert_equal @translator_one.some_api.test_endpoint.call, "returned value"
    assert_equal @translator_two.some_other_api.test_other_endpoint.call, "returned other value"
  end

  def test_local_raises_with_invalid_type
    assert_raises Translator::CallableTypeError do
      Translator.configure do
        service :some_api, base_url: 'http://rest-api.com' do
          endpoint :test_endpoint, local: 2, remote: {}
        end
      end
    end
  end

  def test_local_raises_with_invalid_string
    translator = Translator.configure do
      service :some_api, base_url: 'http://rest-api.com' do
        endpoint :test_endpoint, local: 'SomeNonExistingClass.run', remote: {}
      end
    end
    assert_raises Translator::StringNotEvalableError do
      translator.some_api.test_endpoint.call
    end
  end

  def test_remote_raises_with_anything_other_than_hash
    assert_raises Translator::CallableTypeError do
      Translator.configure do
        service :some_api, base_url: 'http://rest-api.com' do
          endpoint :test_endpoint, local: 2, remote: 'stupid_string'
        end
      end
    end
  end


end
