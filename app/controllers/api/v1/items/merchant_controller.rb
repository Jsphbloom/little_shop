class Api::V1::Items::MerchantController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :unprocessable_entity_response
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  def index
    merchant = Item.find(params[:id]).merchant
    render json: MerchantSerializer.new(merchant)
  end

  private

  def unprocessable_entity_response(e)
    render json: ErrorSerializer.format_error(e, "422"), status: :unprocessable_entity
  end

  def not_found_response(e)
    render json: ErrorSerializer.format_error(e, "404"), status: :not_found
  end
end
