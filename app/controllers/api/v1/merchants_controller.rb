class Api::V1::MerchantsController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :bad_request_response
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  def index
    merchant_list = Merchant.all

    if params[:status].present? && params[:status] == "returned"
      merchant_list = Merchant.with_returned_items
    end

    if params[:sorted] == "age"
      merchant_list = merchant_list.sort_by_age
    end

    if params[:count].present? && params[:count] == "true"
      merchant_list = merchant_list.with_item_count
    end
    render json: MerchantSerializer.new(merchant_list)
  end

  def show
    render json: MerchantSerializer.new(Merchant.find(params[:id]))
  end

  def create
    merchant = Merchant.create(merchant_params)
    render json: MerchantSerializer.new(merchant), status: 201
  end

  def update
    merchant = Merchant.find(params[:id])
    merchant.update(merchant_params)
    render json: MerchantSerializer.new(merchant)
  end

  def destroy
    Merchant.find(params[:id]).destroy
  end

  def find
    raise ActionController::ParameterMissing.new("name") unless params[:name].present? && !params[:name].blank?
    merchant = Merchant.find_by("name ILIKE ?", "%#{params[:name]}%")
    render json: {data: {}} and return unless merchant
    render json: MerchantSerializer.new(merchant)
  end

  def find_all
    raise ActionController::ParameterMissing.new("name") unless params[:name].present? && !params[:name].blank?
    merchants = Merchant.where("name ILIKE ?", "%#{params[:name]}%")
    render json: MerchantSerializer.new(merchants)
  end

  private

  def merchant_params
    params.require(:merchant).permit(:name)
  end

  def bad_request_response(e)
    render json: ErrorSerializer.format_error(e, "400"), status: :bad_request
  end

  def not_found_response(e)
    render json: ErrorSerializer.format_error(e, "404"), status: :not_found
  end
end
