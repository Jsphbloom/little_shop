require "rails_helper"
require "pry"

RSpec.describe "Merchants API", type: :request do
  before do
    Merchant.destroy_all
    # Create dummy merchants with "s" prefix as instance variables
    @sMerchant1 = Merchant.create!(name: "Dummy Merchant 1")
    @sMerchant2 = Merchant.create!(name: "Dummy Merchant 2")
    @sMerchant3 = Merchant.create!(name: "Dummy Merchant 3")
  end

  describe "POST /api/v1/merchants" do
    it "creates a new merchant using the endpoint" do
      post "/api/v1/merchants", params: {merchant: {name: "Dummy Merchant 4"}}
      # binding.pry  # Pause to inspect the response & Merchant state.
      expect(response).to have_http_status(:created).or have_http_status(:ok)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data][:attributes][:name]).to eq("Dummy Merchant 4")
    end
  end

  describe "DELETE /api/v1/merchants/:id" do
    it "deletes an existing merchant created in the before block" do
      # Use sMerchant1 created in before block
      delete "/api/v1/merchants/#{@sMerchant1.id}"
      # binding.pry  # Pause to inspect the merchant before deletion
      expect(response).to have_http_status(:no_content)
      expect(Merchant.find_by(id: @sMerchant1.id)).to be_nil
    end

    it "returns not found when deleting a non-existent merchant" do
      delete "/api/v1/merchants/0"
      expect(response).to have_http_status(:not_found)
    end
  end
end
