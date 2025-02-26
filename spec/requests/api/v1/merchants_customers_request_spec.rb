require "rails_helper"

RSpec.describe "Merchant Customers API", type: :request do
  before do
    Merchant.destroy_all
    Customer.destroy_all
    Invoice.destroy_all
    # Create a merchant and associated customers via invoices.
    @merchant = Merchant.create!(name: "Test Merchant")
    @customer1 = Customer.create!(first_name: "John", last_name: "Doe")
    @customer2 = Customer.create!(first_name: "Jane", last_name: "Smith")
    # Assume invoices are needed for association: Invoice belongs_to merchant and customer.
    Invoice.create!(merchant: @merchant, customer: @customer1, status: "pending")
    Invoice.create!(merchant: @merchant, customer: @customer2, status: "pending")
  end

  describe "GET /api/v1/merchants/:merchant_id/customers" do
    it "returns a list of customers for the merchant" do
      get "/api/v1/merchants/#{@merchant.id}/customers"
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body, symbolize_names: true)
      expect(json_response[:data]).to be_an(Array)
      # Checks that the response contains customer attributes
      expect(json_response[:data].first[:attributes]).to have_key(:first_name)
      expect(json_response[:data].first[:attributes]).to have_key(:last_name)
    end
  end
end
