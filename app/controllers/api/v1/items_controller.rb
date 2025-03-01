class Api::V1::ItemsController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :unprocessable_entity_response
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  def index
    item_list = Item.all
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
    raise ActiveRecord::RecordNotFound if params[:merchant_id].present? && !Merchant.find(params[:merchant_id])
    item = Item.find(params[:id])
    item.update(item_params)
    render json: ItemSerializer.new(item)
  end

  def destroy
    item = Item.find_by(id: params[:id])
    if item
      item.destroy
      head :no_content
    else
      head :not_found
    end
  end

  def find
    if params[:name].present? && (params[:min_price].present? || params[:max_price].present?)
      render json: {error: "Cannot send both name and price parameters"}, status: :bad_request
    elsif params[:name].present?
      item = Item.where("name ILIKE ?", "%#{params[:name]}%").order(:name).first
    elsif params[:min_price].present? && params[:max_price].present?
      item = Item.where("unit_price >= ? AND unit_price <= ?", params[:min_price], params[:max_price]).order(:unit_price).first
    elsif params[:min_price].present?
      item = Item.where("unit_price >= ?", params[:min_price]).order(:unit_price).first
    elsif params[:max_price].present?
      item = Item.where("unit_price <= ?", params[:max_price]).order(:unit_price).first
    else
      render json: {error: "Parameter cannot be missing or empty"}, status: :bad_request
      return
    end

    if item
      render json: ItemSerializer.new(item)
    else
      render json: {error: "Item not found"}, status: :not_found
    end
  end

  def find_all
    items = Item.where("name ILIKE ?", "%#{params[:name]}%")
    render json: ItemSerializer.new(items)
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
