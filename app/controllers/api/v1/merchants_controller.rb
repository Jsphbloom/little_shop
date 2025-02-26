class Api::V1::MerchantsController < ApplicationController
  def create
    merchant = Merchant.create(merchant_params)
    render json: MerchantSerializer.new(merchant)
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

  private

  def merchant_params
    params.require(:merchant).permit(:name)
  end
end
