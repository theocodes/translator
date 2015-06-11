require "sinatra/base"
require "sinatra/json"
require 'byebug'

module TestApi
  class Server < Sinatra::Base

    configure do
      set :port, 9393
    end

    get '/test-api/get_test/:id' do
      json App.new.get_test(params)
    end

    post '/test-api/post_test/:id' do
      json App.new.post_test(params["data"])
    end

    put '/test-api/update_test/:id' do
      json App.new.update_test(params["data"])
    end

    delete '/test-api/delete_test/:id' do
      json App.new.delete_test({id:params["id"]})
    end

    post '/some-other-api/login/:id' do
      json App.new.login(params["data"])
    end

  end

  class App

    def get_test(data)
      { success: true, id: data[:id], role: 'get_test' }
    end

    def post_test(data)
      { success: true, id: data[:id], role: data[:role] }
    end

    def update_test(data)
      { success: true, id: data[:id], role: data[:role] }
    end

    def delete_test(data)
      { success: true, id: data[:id], role: 'delete_test' }
    end

    def login(data)
      { success: true, id: data[:id], role: data[:role] }
    end

  end

end

