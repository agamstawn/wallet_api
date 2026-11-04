class StockPricesController < ApplicationController
  DEFAULT_INDICES = "NIFTY 50".freeze

  rescue_from LatestStockPrice::Error do |e|
    render json: { error: e.message }, status: :bad_gateway
  end

  def price
    render json: LatestStockPrice.price(indices: params.fetch(:indices, DEFAULT_INDICES),
                                        identifier: params[:identifier])
  end

  def prices
    render json: LatestStockPrice.prices(indices: params.fetch(:indices, DEFAULT_INDICES))
  end

  def price_all
    render json: LatestStockPrice.price_all
  end
end
