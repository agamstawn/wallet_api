module LatestStockPrice
  class Client
    def initialize(config = LatestStockPrice.configuration)
      @config = config
    end

    def price(indices:, identifier: nil)
      get("/price", "Indices" => indices, "Identifier" => identifier)
    end

    def prices(indices:)
      get("/prices", "Indices" => indices)
    end

    def price_all
      get("/price_all")
    end

    def get(path, params = {})
      raise ConfigurationError, "RapidAPI key is not configured" if @config.api_key.to_s.empty?

      uri = URI.join(@config.base_url, path)
      uri.query = URI.encode_www_form(params.compact)

      request = Net::HTTP::Get.new(uri)
      request["X-RapidAPI-Key"] = @config.api_key
      request["X-RapidAPI-Host"] = @config.host

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true,
                                 open_timeout: @config.open_timeout,
                                 read_timeout: @config.read_timeout) { |http| http.request(request) }

      unless response.is_a?(Net::HTTPSuccess)
        raise RequestError, "RapidAPI responded with #{response.code}"
      end

      JSON.parse(response.body)
    rescue JSON::ParserError
      raise RequestError, "Invalid JSON from RapidAPI"
    rescue SocketError, Timeout::Error, Errno::ECONNREFUSED => e
      raise RequestError, e.message
    end
  end
end
