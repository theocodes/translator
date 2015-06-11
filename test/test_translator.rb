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


  @@translator = Translator.configure do
    # deploy_config "#{__dir__}/deploy_config_example.yaml"

    service :test_api, namespace: 'TestApi', base_url: 'http://localhost:9393/test-api/' do
      endpoint :post_test, local: { object: 'App', method: :post_test }, remote: { path: '/post_test/:id', verb: :post }
      endpoint :get_test, local: { object: 'App', method: :get_test }, remote: { path: '/get_test/:id', verb: :get }
      endpoint :update_test, local: { object: 'App', method: :update_test }, remote: { path: '/update_test/:id', verb: :update }
      endpoint :delete_test, local: { object: 'App', method: :delete_test }, remote: { path: '/delete_test/:id', verb: :delete }
    end

    service :some_other_api, namespace: 'SomeOtherApi', base_url: 'http://localhost:9393/some-other-api/' do
      endpoint :auth, local: { object: 'Auth', method: :login }, remote: { path: '/login/:id', verb: :post }
    end

  end

  def setup
    @increment_id = 0
  end

  def test_that_it_has_a_version_number
    refute_nil ::Translator::VERSION
  end

  def test_it_responds_to_configure
    assert_respond_to Translator, :configure
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

  def test_all_services
    assert_equal 2, @@translator.services.count
    @@translator.services.each do |service|
      fully_test_service service
    end
  end

  def fully_test_service(service)
    assert_respond_to @@translator, service.name
    service.endpoints.each do |endpoint|
      fully_test_endpoint endpoint
    end
  end

  def fully_test_endpoint(endpoint)
    @increment_id =+ 1
    assert_respond_to endpoint.service, endpoint.name
    assert_kind_of Translator::CallableRequest, endpoint.remote
    fully_test_remote endpoint
    unless endpoint.local.is_a? Translator::NonLocalCallable
      assert_kind_of Translator::CallableObject, endpoint.local
      fully_test_local endpoint
    end
  end

  def fully_test_remote(endpoint)
    assert_equal endpoint.remote.full_raw_url, "#{endpoint.service.base_url}#{endpoint.remote.path}".gsub(/([^:])\/\//, '\1/').freeze
    assert_equal endpoint.remote.processed_url({:id => @increment_id}), "#{endpoint.service.base_url}#{endpoint.local.method.to_s.gsub(":", "")}/#{@increment_id}"
    result = JSON.parse(endpoint.remote({ id: @increment_id, role: "#{endpoint.local.method}" }))
    assert_equal true, result["success"]
    assert_equal @increment_id, result["id"].to_i
    assert_equal "#{endpoint.local.method}", result["role"]
  end

  def fully_test_local(endpoint)
    assert_equal({success: true, id: @increment_id, role: "#{endpoint.local.method}"}, endpoint.local({id: @increment_id, role: "#{endpoint.local.method}"}))
  end

end
