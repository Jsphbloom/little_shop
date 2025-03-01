class Api::V1::ItemsController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :unprocessable_entity_response
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  def index
    item_list = Item.all

    if params[:sorted] == "price"
      item_list = Item.sort_by_price
    end

    render json: ItemSerializer.new(item_list)
  end

  def show
    item = Item.find(params[:id])
    render json: ItemSerializer.new(item)
  end

  def create
    item = Item.create(item_params)
    render json: ItemSerializer.new(item), status: 201
  end

  def update
    if params[:item].present? && params[:item][:merchant_id]
      Merchant.find(params[:item][:merchant_id])
    end
    item = Item.find(params[:id])
    item.update(item_params)
    render json: ItemSerializer.new(item)
  end

  def destroy
    Item.find(params[:id]).destroy
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end

  def unprocessable_entity_response(e)
    render json: ErrorSerializer.format_error(e, "422"), status: :unprocessable_entity
  end

  def not_found_response(e)
    render json: ErrorSerializer.format_error(e, "404"), status: :not_found
  end
end
