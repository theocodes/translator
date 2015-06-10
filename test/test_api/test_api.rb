require "sinatra/base"
require "sinatra/json"

module TestApi
  class Server < Sinatra::Base

    # define a route that uses the helper
    get '/get_test/:id' do
      json App.new.get_test(params["id"])
    end

  end

  class App

    def get_test(data)
      { success: true, id: data[:id], role: 'admin' }
    end

  end

end
