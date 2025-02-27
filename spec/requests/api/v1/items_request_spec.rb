require "rails_helper"

RSpec.describe "Items API", type: :request do
  def parsed_response
    JSON.parse(response.body, symbolize_names: true)
  end

  describe "POST /api/v1/items" do
    it "creates a new item" do
      # Create a merchant via FactoryBot
      merchant = create(:merchant)
      item_params = {
        name: Faker::Commerce.product_name,
        description: Faker::Commerce.material,
        unit_price: Faker::Commerce.price,
        merchant_id: merchant.id
      }
      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
      expect(response).to be_successful

      created_item = Item.last
      expect(created_item).to have_attributes(item_params)

      response_data = parsed_response
      expect(response_data[:data]).to include(
        id: created_item.id.to_s,
        type: "item"
      )
      expect(response_data[:data][:attributes]).to include(item_params)
    end
  end

  describe "PUT /api/v1/items/:id" do
    it "updates an existing item" do
      item = create(:item)
      updated_params = {
        name: Faker::Commerce.product_name,
        description: Faker::Commerce.material,
        unit_price: Faker::Commerce.price,
        merchant_id: item.merchant.id
      }
      headers = {"CONTENT_TYPE" => "application/json"}

      put "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item: updated_params)
      expect(response).to be_successful

      updated_item = Item.find(item.id)
      expect(updated_item).to have_attributes(updated_params)

      response_data = parsed_response
      expect(response_data[:data]).to include(
        id: updated_item.id.to_s,
        type: "item"
      )
      expect(response_data[:data][:attributes]).to include(updated_params)
    end
  end

  describe "DELETE /api/v1/items/:id" do
    it "deletes an existing item" do
      item = create(:item)
      delete "/api/v1/items/#{item.id}"
      expect(response).to have_http_status(:no_content)
      expect(Item.find_by(id: item.id)).to be_nil
    end

    it "returns not found when deleting a non-existent item" do
      delete "/api/v1/items/0"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "sad paths" do
    it "returns error when creating an item with missing attributes" do
      headers = {"CONTENT_TYPE" => "application/json"}
      post "/api/v1/items", headers: headers, params: JSON.generate({})
      expect(response).not_to be_successful
      expect(response.status).to eq(422)

      response_data = parsed_response
      expect(response_data).to have_key(:message)
      expect(response_data[:message]).to eq("param is missing or the value is empty: item")
      expect(response_data).to have_key(:errors)
      expect(response_data[:errors]).to include("422")
    end

    it "returns error when updating an item with missing params" do
      item = create(:item)
      headers = {"CONTENT_TYPE" => "application/json"}
      put "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item: {})
      expect(response).not_to be_successful
      expect([400, 404]).to include(response.status)
    end
  end
end
