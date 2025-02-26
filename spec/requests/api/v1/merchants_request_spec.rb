require "rails_helper"
# bundle exec rspec spec/requests/api/v1/merchants_request_spec.rb
RSpec.describe "Merchants API", type: :request do
  describe "POST /api/v1/merchants" do
    it "creates a new merchant using the endpoint" do
      post "/api/v1/merchants", params: {merchant: {name: "Dummy Merchant 1"}}
      expect(response).to have_http_status(:created).or have_http_status(:ok)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data][:attributes][:name]).to eq("Dummy Merchant 1")
    end
  end

  describe "DELETE /api/v1/merchants/:id" do
    it "deletes an existing merchant created via the endpoint" do
      post "/api/v1/merchants", params: {merchant: {name: "Dummy Merchant 2"}}
      json = JSON.parse(response.body, symbolize_names: true)
      merchant_id = json[:data][:id]

      delete "/api/v1/merchants/#{merchant_id}"
      expect(response).to have_http_status(:no_content)
      expect(Merchant.find_by(id: merchant_id)).to be_nil
    end

    it "returns not found when deleting a non-existent merchant" do
      delete "/api/v1/merchants/0"
      expect(response).to have_http_status(:not_found)
    end
  end
end
