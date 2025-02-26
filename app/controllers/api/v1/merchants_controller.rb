class Api::V1::MerchantsController < ApplicationController
  def create
    merchant = Merchant.create(merchant_params)
    render json: MerchantSerializer.new(merchant), status: 201
  rescue ActionController::ParameterMissing => exception
    render json: {
      message: exception.message,
      errors: ["422"]
    }, status: :unprocessable_entity
  end

  def update
    merchant = Merchant.find(params[:id])
    merchant.update(merchant_params)
    render json: MerchantSerializer.new(merchant)
  end

  private

  def merchant_params
    params.require(:merchant).permit(:name)
  end
end
