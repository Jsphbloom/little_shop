class Api::V1::MerchantsController < ApplicationController

  def index
    merchant_list = Merchant.all
    render json: MerchantSerializer.new(merchant_list)
  end

  def create
    merchant = Merchant.create(merchant_params)
    render json: MerchantSerializer.new(merchant)
  end

  private

  def merchant_params
    params.require(:merchant).permit(:name)
  end
end
