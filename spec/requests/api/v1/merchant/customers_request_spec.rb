require "rails_helper"
RSpec.describe "Merchant Customers API", type: :request do
  let(:merchant) { create(:merchant) }

  before do
    create_list(:invoice, 50, merchant: merchant)
  end

  def parsed_response
    JSON.parse(response.body, symbolize_names: true)
  end

  describe "endpoints" do
    describe "GET /api/v1/merchants/:merchant_id/customers" do
      it "returns a list of customers for the merchant in JSONAPI format" do
        get "/api/v1/merchants/#{merchant.id}/customers"

        expect(response).to be_successful
        expect(response.status).to eq(200)

        response_data = parsed_response

        expect(response_data).to have_key(:data)
        expect(response_data[:data]).to be_an(Array)

        response_customers = response_data[:data]

        expect(response_customers.length).to eq(50)

        response_data[:data].each do |customer|
          expect(customer).to have_key(:id)
          expect(customer[:id]).to be_a(String)

          expect(customer).to have_key(:type)
          expect(customer[:type]).to eq("customer")

          expect(customer).to have_key(:attributes)
          expect(customer[:attributes]).to be_a(Hash)

          attributes = customer[:attributes]

          expect(attributes).to have_key(:first_name)
          expect(attributes[:first_name]).to be_a(String)

          expect(attributes).to have_key(:last_name)
          expect(attributes[:last_name]).to be_a(String)
        end
      end
    end
  end

  describe "sad paths" do
    it "handles invalid merchant id gracefully" do
      get "/api/v1/merchants/8923987297/customers"

      expect(response).not_to be_successful
      expect(response.status).to eq(404)

      response_data = parsed_response

      expect(response_data[:errors]).to eq(["404"])
      expect(response_data[:message]).to eq("Couldn't find Merchant with 'id'=8923987297")
    end
  end
end
