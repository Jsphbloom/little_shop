require "rails_helper"
# bundle exec rspec spec/requests/api/v1/merchants_customers_request_spec.rb

RSpec.describe "Merchant Customers API", type: :request do
  before do
    Merchant.destroy_all
    Customer.destroy_all
    Invoice.destroy_all

    # Manually create a merchant and associated customers.
    @merchant = Merchant.create!(name: "Test Merchant")
    @customer1 = Customer.create!(first_name: "John", last_name: "Doe")
    @customer2 = Customer.create!(first_name: "Jane", last_name: "Smith")

    # Associate customers with the merchant via invoices.
    Invoice.create!(merchant: @merchant, customer: @customer1)
    Invoice.create!(merchant: @merchant, customer: @customer2)
  end

  describe "GET /api/v1/merchants/:merchant_id/customers" do
    it "returns a list of customers for the merchant in JSONAPI format" do
      get "/api/v1/merchants/#{@merchant.id}/customers"
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body, symbolize_names: true)
      expect(json_response).to have_key(:data)
      expect(json_response[:data]).to be_an(Array)
      json_response[:data].each do |customer|
        expect(customer).to have_key(:id)
        expect(customer).to have_key(:type)
        expect(customer[:type]).to eq("customer")
        expect(customer).to have_key(:attributes)
        expect(customer[:attributes]).to have_key(:first_name)
        expect(customer[:attributes]).to have_key(:last_name)
      end
    end
  end
end
