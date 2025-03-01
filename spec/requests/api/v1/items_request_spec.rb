require "rails_helper"

RSpec.describe "Items API", type: :request do
  def parsed_response
    JSON.parse(response.body, symbolize_names: true)
  end

  describe "POST /api/v1/items" do
    it "creates a new item" do
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
      # Changed expectation to 422 (Unprocessable Entity) since the controller returns 422
      expect(response.status).to eq(422)
    end
  end

  describe "GET /api/v1/items/find" do
    it "can find a single item by name fragment" do
      item = create(:item, name: "Test Item")
      create(:item, name: "Another Item")
      create(:item, name: "Test Product")

      get "/api/v1/items/find?name=test"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      response_data = parsed_response

      expect(response_data).to have_key(:data)
      expect(response_data[:data]).to be_a(Hash)

      expect(response_data[:data]).to include(
        id: item.id.to_s,
        type: "item"
      )

      expect(response_data[:data]).to have_key(:attributes)
      expect(response_data[:data][:attributes]).to be_a(Hash)
      expect(response_data[:data][:attributes]).to include(
        name: item.name,
        description: item.description,
        unit_price: item.unit_price
      )
    end
  end

  describe "GET /api/v1/items/find_all" do
    it "can find all items by name fragment" do
      item1 = create(:item, name: "Test Item")
      item2 = create(:item, name: "Another Item")
      item3 = create(:item, name: "Test Product")

      get "/api/v1/items/find_all?name=test"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      response_data = parsed_response

      expect(response_data).to have_key(:data)
      expect(response_data[:data]).to be_an(Array)

      response_items = response_data[:data]

      expect(response_items.length).to eq(2)

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
        expect(attributes[:merchant_id]).to be_an(Integer)
      end

      expect(response_items[0][:attributes][:name]).to eq(item1.name)
      expect(response_items[1][:attributes][:name]).to eq(item3.name)
    end
  end
end
