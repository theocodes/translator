require 'minitest_helper'
require 'translator'
require 'translator/callable/callable'
require 'translator/callable/callable_request'
require 'json'

# Test subject
require_relative 'test_api/test_api.rb'

# Note: Test server must be running (test/test_api).
# While it's not ideal to create such dependency for testing,
# it is vital that remote callable gets tested that it maps to the right
# HTTP verb, passed params etc.
#
# To run it, install shotgun, go to /test/test_api/ and run shotgun :)

class TestTranslator < Minitest::Test
  include TestApi

  def setup
    @translator = Translator.configure do
      service :test_api, namespace: 'TestApi', base_url: 'http://localhost:9393/test-api/' do
        endpoint :get_test, local: { object: 'App', method: :get_test }, remote: { path: '/get_test/:id', verb: :get }
        endpoint :post_test, local: { object: 'App', method: :post_test }, remote: { path: '/post_test/:id', verb: :post }
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
    assert_kind_of Translator::CallableObject, @translator.test_api.get_test.local
  end

  def test_endpoint_returns_a_remote_callable
    assert_kind_of Translator::CallableRequest, @translator.test_api.get_test.remote
  end

  def test_remote_callable_subject
    assert_equal @translator.test_api.get_test.remote.base_url, "http://localhost:9393/test-api/"
    assert_equal @translator.test_api.get_test.remote.full_raw_url, "http://localhost:9393/test-api/get_test/:id"
    assert_equal @translator.test_api.get_test.remote.path, "/get_test/:id"
    assert_equal @translator.test_api.get_test.remote.verb, :get
    assert_equal @translator.test_api.get_test.remote.processed_url({:id => 1}), "http://localhost:9393/test-api/get_test/1"
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

  def test_remote_raises_with_invalid_type
    assert_raises Translator::CallableTypeError do
      Translator.configure do
        service :some_api, namespace: 'TestApi', base_url: 'http://rest-api.com' do
          endpoint :test_endpoint, local: { object: 'App', method: 'get_test' }, remote: "wrong type"
        end
      end
    end
  end

  def test_get_local
    assert_equal({ success: true, id: 1, role: 'admin' }, @translator.test_api.get_test.local({ id: 1, role: 'admin'}))
  end

  def test_post_local
    assert_equal({ success: true, id: 1, role: 'monkey' }, @translator.test_api.post_test.local({ id: 1, role: 'monkey'}))
  end

  def test_get_remote
    result = JSON.parse(@translator.test_api.get_test.remote({ id: 1, role: 'admin'}))
    assert_equal true, result["success"]
    assert_equal 1, result["id"].to_i
    assert_equal 'admin', result["role"]
  end

  def test_post_remote
    result = JSON.parse(@translator.test_api.post_test.remote({ id: 1, role: 'admin'}))
    assert_equal true, result["success"]
    assert_equal 1, result["id"].to_i
    assert_equal 'admin', result["role"]
  end



end
