require 'minitest_helper'
require 'translator'
require 'translator/callable'
require 'translator/local_callable'
require 'translator/remote_callable'
require 'translator/callable_request'
require 'json'

# Test subject
require_relative 'test_api/test_api.rb'

class TestTranslator < Minitest::Test
  include TestApi

  def setup

    @translator = Translator.configure do
      service :test_api, namespace: 'TestApi', base_url: 'http://localhost:9393/test-api/' do
        endpoint :get_test, local: { object: 'App', method: :get_test }, remote: { path: '/get_test/:id', verb: :get }
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
    assert_respond_to @translator, :test_api
  end

  def test_it_responds_to_endpoint_method
    assert_respond_to @translator.test_api, :get_test
  end

  def test_endpoint_returns_a_local_callable
    assert_kind_of Translator::LocalCallable, @translator.test_api.get_test.local
  end

  def test_remote_callable_subject
    byebug
    assert_equal @translator.test_api.get_test.remote.base_url, "http://localhost:9393/test-api/"
    assert_equal @translator.test_api.get_test.remote.full_raw_url, "http://localhost:9393/test-api/get_test/:id"
    assert_equal @translator.test_api.get_test.remote.path, "/get_test/:id"
    assert_equal @translator.test_api.get_test.remote.verb, :get
    assert_equal @translator.test_api.get_test.remote.processed_url( url_params: {:id => 1}), "http://localhost:9393/test-api/get_test/1"
  end

  def test_it_raises_with_unknown_params
    skip
    assert_raises Translator::UnknownParamError do
      @translator.test_api.get_test.remote.processed_url( url_params: {:not_declared => 1})
    end
  end

  def test_it_takes_a_proc_for_local
    skip
    my_proc = Proc.new do
      TestApi::App.new.get_test(1)
    end

    my_translator = Translator.configure do
      service :test_api do
        endpoint :test_endpoint, local: my_proc
      end
    end
    assert_equal my_translator.test_api.get_test.call, { success: true, id: 1 }
  end

  def test_it_takes_string_for_local
    skip
    assert_equal Lotus::Awards.adapter.test_api.get_test.call({id: 1, name: 'someti'}) , { success: true }
  end

  def test_local_raises_with_invalid_type
    skip
    assert_raises Translator::CallableTypeError do
      Translator.configure do
        service :some_api, base_url: 'http://rest-api.com' do
          endpoint :test_endpoint, local: 2, remote: {}
        end
      end
    end
  end

  def test_local_raises_with_invalid_string
    skip
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
    skip
    assert_raises Translator::CallableTypeError do
      Translator.configure do
        service :some_api, base_url: 'http://rest-api.com' do
          endpoint :test_endpoint, local: 2, remote: 'stupid_string'
        end
      end
    end
  end

  def test_get_local
    result = { success: true, id: 1, role: 'admin' }
    assert_equal result, @translator.test_api.get_test({ id: 1, role: 'admin'}, type: 'local')
  end

  def test_get_remote
    skip
  end

end
