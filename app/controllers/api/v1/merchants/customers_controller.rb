class Api::V1::Merchants::CustomersController < ApplicationController
  # GET /api/v1/merchants/:merchant_id/customers
  # This action retrieves the merchant using the dynamic :merchant_id parameter.
  # It then calls merchant.customers (the full association without filtering)
  # and renders a JSON representation via CustomerSerializer.
  # 
  # In your controller, when you call "merchant.customers", that method returns an array (even if it contains only one element or is empty).
  # When you pass that array to your JSONAPI::Serializer (e.g., CustomerSerializer), it wraps the array in a "data" key in the JSON response.
  # This behavior—returning "data" as an array—is built into the JSONAPI::Serializer so that you always get an array, even if there’s one or zero resources.
  def index
    merchant = Merchant.find(params[:merchant_id])
    render json: CustomerSerializer.new(merchant.customers)
  end
end
