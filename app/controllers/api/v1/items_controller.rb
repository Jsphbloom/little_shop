class Api::V1::ItemsController < ApplicationController
  def create
    item = Item.create(item_params)
    render json: ItemSerializer.new(item), status: 201
  rescue ActionController::ParameterMissing => exception
    render json: {
      message: exception.message,
      errors: ["422"]
    }, status: :unprocessable_entity
  end

  def update
    item = Item.find(params[:id])
    return if params[:merchant_id] && !Merchant.find(params[:merchant_id])
    item.update(item_params)
    render json: ItemSerializer.new(item)
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end
