class Api::V1::Merchants::CustomersController < ApplicationController
  # This controller is nested under merchants.
  # It handles endpoints matching:
  #   GET /api/v1/merchants/:merchant_id/customers
  # where :merchant_id is a dynamic segment from the route.
  #
  # The index action finds the merchant using the provided merchant_id,
  # then returns a JSON response for the merchant's associated customers.
  def index
    merchant = Merchant.find(params[:merchant_id])  # Retrieve the merchant via the dynamic :merchant_id
    render json: CustomerSerializer.new(merchant.customers)
  end
end
