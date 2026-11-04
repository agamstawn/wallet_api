require "test_helper"

class LatestStockPriceTest < ActiveSupport::TestCase
  def client_with_key(key)
    config = LatestStockPrice::Configuration.new
    config.api_key = key
    LatestStockPrice::Client.new(config)
  end

  test "raises when api key is missing" do
    assert_raises(LatestStockPrice::ConfigurationError) { client_with_key(nil).price_all }
  end

  test "price_all returns parsed data" do
    client = client_with_key("dummy")
    def client.get(*) = [{ "symbol" => "RELIANCE", "lastPrice" => 100 }]
    assert_equal "RELIANCE", client.price_all.first["symbol"]
  end
end
