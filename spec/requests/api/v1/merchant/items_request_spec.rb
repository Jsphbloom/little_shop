require "rails_helper"
RSpec.describe "Merchant Items API", type: :request do
  let(:merchant) { create(:merchant) }

  before do
    create_list(:item, 25, merchant: create(:merchant))
    create_list(:item, 25, merchant: merchant)
  end

  def parsed_response
    JSON.parse(response.body, symbolize_names: true)
  end
  describe "GET /api/v1/merchants/:id/items" do
    it "returns all items belonging to merchant" do
      get "/api/v1/merchants/#{merchant.id}/items"

      expect(response).to be_successful

      response_data = parsed_response

      expect(response_data).to have_key(:data)
      expect(response_data[:data]).to be_an(Array)

      response_items = response_data[:data]

      expect(response_items.length).to eq(25)

      response_items.each do |item|
        expect(item).to have_key(:id)
        expect(item[:id]).to be_a(String)

        expect(item).to have_key(:type)
        expect(item[:type]).to eq("item")

        expect(item).to have_key(:attributes)
        expect(item[:attributes]).to be_a(Hash)

        attributes = item[:attributes]

        expect(attributes).to have_key(:name)
        expect(attributes[:name]).to be_a(String)

        expect(attributes).to have_key(:description)
        expect(attributes[:description]).to be_a(String)

        expect(attributes).to have_key(:unit_price)
        expect(attributes[:unit_price]).to be_a(Float)

        expect(attributes).to have_key(:merchant_id)
        expect(attributes[:merchant_id]).to eq(merchant.id)
      end
    end
  end

  describe "sad paths" do
    it "handles invalid merchant id gracefully" do
      get "/api/v1/merchants/8923987297/items"

      expect(response).not_to be_successful
      expect(response.status).to eq(404)

      response_data = parsed_response

      expect(response_data[:errors]).to eq(["404"])
      expect(response_data[:message]).to eq("Couldn't find Merchant with 'id'=8923987297")
    end
  end
end
