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

  end

  class App

    def get_test(data)
      { success: true, id: data[:id], role: 'admin' }
    end

    def post_test(data)
      { success: true, id: data[:id], role: data[:role] }
    end

  end

end

