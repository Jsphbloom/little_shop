class Api::V1::Merchant::CouponsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  def index
    merchant = Merchant.find(params[:merchant_id])
    coupons = merchant.coupons
    render json: CouponSerializer.new(coupons)
  end

  private

  def not_found_response(e)
    render json: ErrorSerializer.format_error(e, "404"), status: :not_found
  end
end
