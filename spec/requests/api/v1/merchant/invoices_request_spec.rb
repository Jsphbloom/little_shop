require "rails_helper"
RSpec.describe "Merchant Invoices API", type: :request do
  let(:merchant) { create(:merchant) }

  before do
    create_list(:invoice, 25, merchant: merchant, status: "returned")
    create_list(:invoice, 30, merchant: merchant, status: "shipped")
    create_list(:invoice, 35, merchant: merchant, status: "packaged")
  end

  def parsed_response
    JSON.parse(response.body, symbolize_names: true)
  end

  describe "endpoints" do
    describe "GET /api/v1/merchants/:merchant_id/invoices" do
      it "returns list of invoices for a merchant filtered by status" do
        get "/api/v1/merchants/#{merchant.id}/invoices?status=shipped"

        expect(response).to be_successful
        expect(response.status).to eq(200)

        response_data = parsed_response

        expect(response_data).to have_key(:data)
        expect(response_data[:data]).to be_an(Array)

        response_invoices = response_data[:data]

        expect(response_invoices.length).to eq(30)

        response_invoices.each do |invoice|
          expect(invoice).to have_key(:id)
          expect(invoice[:id]).to be_a(String)

          expect(invoice).to have_key(:type)
          expect(invoice[:type]).to eq("invoice")

          expect(invoice).to have_key(:attributes)
          expect(invoice[:attributes]).to be_a(Hash)

          attributes = invoice[:attributes]

          expect(attributes).to have_key(:customer_id)
          expect(attributes[:customer_id]).to be_an(Integer)

          expect(attributes).to have_key(:merchant_id)
          expect(attributes[:merchant_id]).to eq(merchant.id)

          expect(attributes).to have_key(:status)
          expect(attributes[:status]).to eq("shipped")
        end
      end
    end
  end

  describe "sad paths" do
    it "handles nonexistent merchant id gracefully" do
      get "/api/v1/merchants/8923987297/customers"

      expect(response).not_to be_successful
      expect(response.status).to eq(404)

      response_data = parsed_response

      expect(response_data[:errors]).to eq(["404"])
      expect(response_data[:message]).to eq("Couldn't find Merchant with 'id'=8923987297")
    end
  end
end
