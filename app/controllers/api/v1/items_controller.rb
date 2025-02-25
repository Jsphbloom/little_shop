class Api::V1::ItemsController < ApplicationController

  def index
    merchant_list = Merchant.all
    render json: ItemSerializer.format_merchants(merchant_list)
  end

  def create
    item = Item.create(item_params)
    render json: ItemSerializer.new(item)
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end
