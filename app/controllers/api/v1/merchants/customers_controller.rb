class Api::V1::Merchants::CustomersController < ApplicationController
  # GET /api/v1/merchants/:merchant_id/customers
  # This action retrieves the merchant using the dynamic :merchant_id parameter.
  # It then uses the Merchant model's "customers" association defined as:
  #   has_many :customers, -> { distinct }, through: :invoices
  # Finally, it renders a JSON response with the merchant's unique customers using CustomerSerializer.
  def index
    merchant = Merchant.find(params[:merchant_id])
    render json: CustomerSerializer.new(merchant.customers)
  end
end

# The controller’s index action retrieves the merchant using params[:merchant_id].
# It then calls the "customers" association on that merchant—the association is defined in the Merchant model as:
#   has_many :customers, -> { distinct }, through: :invoices
# Finally, the controller renders the JSON response using CustomerSerializer.