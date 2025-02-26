class Api::V1::MerchantsController < ApplicationController

  def index
    merchant_list = Merchant.all
    render json: MerchantSerializer.new(merchant_list)
  end

  def create
    merchant = Merchant.create(merchant_params)
    render json: MerchantSerializer.new(merchant), status: 201
  rescue ActionController::ParameterMissing => exception
    render json: {message: exception.message, errors: ["422"]}, status: :unprocessable_entity
  end

  def destroy
    merchant = Merchant.find_by(id: params[:id])
    if merchant
      merchant.destroy
      head :no_content
    else
      head :not_found
    end
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
