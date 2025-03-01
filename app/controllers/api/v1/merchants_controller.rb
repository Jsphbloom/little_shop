class Api::V1::MerchantsController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :unprocessable_entity_response
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  def index
    merchant_list = Merchant.all

    if params[:status].present? && params[:status] == "returned"
      merchant_list = Merchant.with_returned_items
    end

    if params[:sort].present?
      merchant_list = merchant_list.sort_by(params[:sort])
    end

    render json: MerchantSerializer.new(merchant_list)
  end

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.new(merchant)
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
    merchant = Merchant.find_by(id: params[:id])
    if merchant
      merchant.destroy
      head :no_content
    else
      head :not_found
    end
  end

  def find
    if params[:name].blank?
      render json: {error: "Parameter cannot be missing or empty"}, status: :bad_request
      return
    end

    merchant = Merchant.where("name ILIKE ?", "%#{params[:name]}%").order(:name).first
    if merchant
      render json: MerchantSerializer.new(merchant)
    else
      render json: {error: "Merchant not found"}, status: :not_found
    end
  end

  def find_all
    merchants = Merchant.where("name ILIKE ?", "%#{params[:name]}%").order(:name)
    render json: MerchantSerializer.new(merchants)
  end

  private

  def merchant_params
    params.require(:merchant).permit(:name)
  end

  def unprocessable_entity_response(e)
    render json: ErrorSerializer.format_error(e, "422"), status: :unprocessable_entity
  end

  def not_found_response(e)
    render json: ErrorSerializer.format_error(e, "404"), status: :not_found
  end
end
