class Api::V1::Items::MerchantController < ApplicationController
  def index
    if Item.find(params[:id])
      merchant = Item.find(params[:id]).merchant
      render json: MerchantSerializer.new(merchant)
    end
  end
end
