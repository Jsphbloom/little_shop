class Api::V1::Merchant::InvoicesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  def index
    merchant = Merchant.find(params[:merchant_id])
    invoices = merchant.invoices.where("status = '#{params[:status]}'")
    render json: InvoiceSerializer.new(invoices)
  end

  private

  def not_found_response(e)
    render json: ErrorSerializer.format_error(e, "404"), status: :not_found
  end
end
