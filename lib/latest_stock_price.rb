require "net/http"
require "json"
require "uri"
require_relative "latest_stock_price/version"
require_relative "latest_stock_price/errors"
require_relative "latest_stock_price/configuration"
require_relative "latest_stock_price/client"

module LatestStockPrice
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    def client
      Client.new(configuration)
    end

    def price(indices:, identifier: nil)
      client.price(indices: indices, identifier: identifier)
    end

    def prices(indices:)
      client.prices(indices: indices)
    end

    def price_all
      client.price_all
    end
  end
end
