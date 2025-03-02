class Api::V1::ItemsController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :bad_request_response
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

  def find
    raise ActionController::ParameterMissing.new("name") unless params[:name] || params[:min_price] || params[:max_price]

    if params[:name].present? &&
        (params[:min_price].present? || params[:max_price].present?)
      render json: {message: "Cannot send both name and price parameters", errors: ["400"]}, status: :bad_request
      return
    end

    [:name, :min_price, :max_price].each do |p|
      raise ActionController::ParameterMissing.new(p) if !params[p].nil? && params[p].blank?
    end

    [:min_price, :max_price].each do |p|
      if params[p] && params[p].to_f < 0
        render json: {message: "#{p} cannot be less than 0", errors: ["400"]}, status: :bad_request
        return
      end
    end

    if params[:min_price] && params[:max_price] && params[:min_price].to_f > params[:max_price].to_f
      render json: {message: "min_price cannot be greater than max price", errors: ["400"]}, status: :bad_request
      return
    end

    item = if params[:name].present?
      Item.find_by("name ILIKE ?", "%#{params[:name]}%")
    elsif params[:min_price].present? && params[:max_price].present?
      Item.find_by("unit_price >= ? AND unit_price <= ?", params[:min_price], params[:max_price])
    elsif params[:min_price].present?
      Item.find_by("unit_price >= ?", params[:min_price])
    elsif params[:max_price].present?
      Item.find_by("unit_price <= ?", params[:max_price])
    end
    render json: {data: {}} and return unless item
    render json: ItemSerializer.new(item)
  end

  def find_all
    if params[:name].present? &&
        (params[:min_price].present? || params[:max_price].present?)
      render json: {message: "Cannot send both name and price parameters", errors: ["400"]}, status: :bad_request
      return
    end

    [:name, :min_price, :max_price].each do |p|
      raise ActionController::ParameterMissing.new(p) if !params[p].nil? && params[p].blank?
    end

    [:min_price, :max_price].each do |p|
      if params[p] && params[p].to_f < 0
        render json: {message: "#{p} cannot be less than 0", errors: ["400"]}, status: :bad_request
        return
      end
    end

    if params[:min_price] && params[:max_price] && params[:min_price].to_f > params[:max_price].to_f
      render json: {message: "min_price cannot be greater than max price", errors: ["400"]}, status: :bad_request
      return
    end

    items = if params[:name].present?
      Item.where("name ILIKE ?", "%#{params[:name]}%")
    elsif params[:min_price].present? && params[:max_price].present?
      Item.where("unit_price >= ? AND unit_price <= ?", params[:min_price], params[:max_price])
    elsif params[:min_price].present?
      Item.where("unit_price >= ?", params[:min_price])
    elsif params[:max_price].present?
      Item.where("unit_price <= ?", params[:max_price])
    end
    render json: ItemSerializer.new(items)
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end

  def bad_request_response(e)
    render json: ErrorSerializer.format_error(e, "400"), status: :bad_request
  end

  def not_found_response(e)
    render json: ErrorSerializer.format_error(e, "404"), status: :not_found
  end
end
