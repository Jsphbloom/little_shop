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
    head :no_content
  end

  def find
    if invalid_find_params?
      render json: {error: "Cannot send both name and price parameters"}, status: :bad_request and return
    elsif params[:name].blank? && params[:min_price].blank? && params[:max_price].blank?
      render json: {error: "Parameter cannot be missing or empty"}, status: :bad_request and return
    end

    item = find_item
    if item
      render json: ItemSerializer.new(item)
    else
      render json: {error: "Item not found"}, status: :not_found
    end
  end

  def find_all
    if invalid_find_params?
      render json: {error: "Cannot send both name and price parameters"}, status: :bad_request and return
    elsif params[:name].blank? && params[:min_price].blank? && params[:max_price].blank?
      render json: {error: "Parameter cannot be missing or empty"}, status: :bad_request and return
    end

    items = find_items
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

  def invalid_find_params?
    params[:name].present? && (params[:min_price].present? || params[:max_price].present?)
  end

  def find_item
    if params[:name].present?
      Item.where("name ILIKE ?", "%#{params[:name]}%").order(:name).first
    elsif params[:min_price].present? && params[:max_price].present?
      Item.where("unit_price >= ? AND unit_price <= ?", params[:min_price], params[:max_price]).order(:unit_price).first
    elsif params[:min_price].present?
      Item.where("unit_price >= ?", params[:min_price]).order(:unit_price).first
    elsif params[:max_price].present?
      Item.where("unit_price <= ?", params[:max_price]).order(:unit_price).first
    else
      nil
    end
  end

  def find_items
    if params[:name].present?
      Item.where("name ILIKE ?", "%#{params[:name]}%").order(:name)
    elsif params[:min_price].present? && params[:max_price].present?
      Item.where("unit_price >= ? AND unit_price <= ?", params[:min_price], params[:max_price]).order(:unit_price)
    elsif params[:min_price].present?
      Item.where("unit_price >= ?", params[:min_price]).order(:unit_price)
    elsif params[:max_price].present?
      Item.where("unit_price <= ?", params[:max_price]).order(:unit_price)
    else
      []
    end
  end
end
