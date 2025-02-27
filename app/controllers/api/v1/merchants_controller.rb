class Api::V1::MerchantsController < ApplicationController
  def index
    merchant_list = Merchant.all

    if params[:status].present? && params[:status] == "returned"
      merchant_list = Merchant.with_returned_items
    end

    if params[:sort] == "desc"
      merchant_list = merchant_list.order(created_at: :desc)
    elsif params[:sort] == "asc"
      merchant_list = merchant_list.order(created_at: :asc)
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
  rescue ActionController::ParameterMissing => exception
    render json: {message: exception.message, errors: ["422"]}, status: :unprocessable_entity
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

  private

  def merchant_params
    params.require(:merchant).permit(:name)
  end
end
