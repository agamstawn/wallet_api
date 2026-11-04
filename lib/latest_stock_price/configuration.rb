module LatestStockPrice
  class Configuration
    attr_accessor :api_key, :host, :open_timeout, :read_timeout

    def initialize
      @api_key = ENV["RAPIDAPI_KEY"]
      @host = "latest-stock-price.p.rapidapi.com"
      @open_timeout = 5
      @read_timeout = 10
    end

    def base_url
      "https://#{host}"
    end
  end
end
