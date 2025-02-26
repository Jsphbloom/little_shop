require "rails_helper"
# bundle exec rspec spec/requests/api/v1/items_request_spec.rb

RSpec.describe "Items API", type: :request do
  describe "POST /api/v1/items" do
    it "creates a new item using the endpoint" do
      # First, create a merchant for association via the API.
      post "/api/v1/merchants", params: {merchant: {name: "Item Merchant"}}
      merchant = JSON.parse(response.body, symbolize_names: true)

      post "/api/v1/items", params: {
        item: {
          name: "Dummy Item 1",
          description: "Dummy description 1",
          unit_price: 10.0,
          merchant_id: merchant[:data][:id]
        }
      }
      expect(response).to have_http_status(:created).or have_http_status(:ok)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data][:attributes][:name]).to eq("Dummy Item 1")
    end
  end

  describe "DELETE /api/v1/items/:id" do
    it "deletes an existing item created via the endpoint" do
      # Create a merchant and then an item via the API endpoints.
      post "/api/v1/merchants", params: {merchant: {name: "Item Merchant"}}
      merchant = JSON.parse(response.body, symbolize_names: true)

      post "/api/v1/items", params: {
        item: {
          name: "Dummy Item 2",
          description: "Dummy description 2",
          unit_price: 20.0,
          merchant_id: merchant[:data][:id]
        }
      }
      item = JSON.parse(response.body, symbolize_names: true)

      delete "/api/v1/items/#{item[:data][:id]}"
      expect(response).to have_http_status(:no_content)
      expect(Item.find_by(id: item[:data][:id])).to be_nil
    end

    it "returns not found when deleting a non-existent item" do
      delete "/api/v1/items/0"
      expect(response).to have_http_status(:not_found)
    end
  end
end
