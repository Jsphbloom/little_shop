class Api::V1::ItemsController < ApplicationController
  def create
    item = Item.create(item_params)
    render json: ItemSerializer.new(item)
  end

  # New destroy action: deletes the item record and returns 204 (or 404 if not found)
  def destroy
    item = Item.find_by(id: params[:id])
    if item
      item.destroy
      head :no_content
    else
      head :not_found
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end
