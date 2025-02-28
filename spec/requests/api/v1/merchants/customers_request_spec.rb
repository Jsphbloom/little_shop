require "rails_helper"
RSpec.describe "Merchant Customers API", type: :request do
  before do
    Merchant.destroy_all
    Customer.destroy_all
    Invoice.destroy_all

    @merchant = create(:merchant, name: Faker::Company.name)
    @customer1 = create(:customer, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name)
    @customer2 = create(:customer, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name)

    create(:invoice, merchant: @merchant, customer: @customer1)
    create(:invoice, merchant: @merchant, customer: @customer2)
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
