class Api::V1::MerchantsController < ApplicationController
  def create
    merchant = Merchant.create(merchant_params)
    render json: MerchantSerializer.new(merchant)
  end

  # New destroy action: deletes the merchant record and returns 204 (or 404 if not found)
  def destroy
    merchant = Merchant.find_by(id: params[:id])
    if merchant
      merchant.destroy
      head :no_content
    else
      head :not_found
    end
  end

  private

  def merchant_params
    params.require(:merchant).permit(:name)
  end
end
