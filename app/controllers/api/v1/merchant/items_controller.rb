class Api::V1::Merchant::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  def index
    raise ActiveRecord::RecordNotFound.new("Merchant not found") unless Merchant.find(params[:id])
    items = Item.where(merchant_id: params[:id])
    render json: ItemSerializer.new(items)
  end

  private

  def not_found_response(e)
    render json: ErrorSerializer.format_error(e, "404"), status: :not_found
  end
end
