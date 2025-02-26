require "rails_helper"

RSpec.describe "Items Merchant API", type: :request do
  let(:merchant) { create(:merchant) }
  let(:item) { create(:item, merchant: merchant) }

  before do
    create_list(:item, 25, merchant: create(:merchant))
    create_list(:item, 25, merchant: create(:merchant))
    create_list(:item, 25, merchant: merchant)
  end

  def parsed_response
    JSON.parse(response.body, symbolize_names: true)
  end
  describe "GET /api/v1/items/:id/merchant" do
    it "returns merchant for item" do
      get "/api/v1/items/#{item.id}/merchant"

      expect(response).to be_successful

      response_data = parsed_response

      expect(response_data).to have_key(:data)
      expect(response_data[:data]).to include(
        id: merchant.id.to_s,
        type: "merchant"
      )
      expect(response_data[:data]).to have_key(:attributes)
      expect(response_data[:data][:attributes]).to be_a(Hash)

      expect(response_data[:data][:attributes]).to have_key(:name)
      expect(response_data[:data][:attributes][:name]).to eq(merchant.name)
    end
  end

  describe "sad paths" do
    it "handles invalid item id gracefully" do
      get "/api/v1/items/8923987297/merchant"

      expect(response).not_to be_successful
      expect(response.status).to eq(400).or eq(404)
    end

    it "handles string item id gracefully" do
      get "/api/v1/items/string-instead-of-integer/merchant"

      expect(response).not_to be_successful
      expect(response.status).to eq(400).or eq(404)
    end
  end
end
