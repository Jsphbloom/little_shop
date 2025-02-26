class Api::V1::Merchant::ItemsController < ApplicationController
  def index
    if Merchant.find(params[:id])
      items = Item.where(merchant_id: params[:id])
      render json: ItemSerializer.new(items)
    end
  end
end
