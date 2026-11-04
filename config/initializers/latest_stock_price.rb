require Rails.root.join("lib/latest_stock_price")

LatestStockPrice.configure do |config|
  config.api_key = ENV["RAPIDAPI_KEY"]
end
