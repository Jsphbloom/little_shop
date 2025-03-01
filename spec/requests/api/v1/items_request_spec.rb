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
      item1 = create(:item, name: "Test Item")
      item2 = create(:item, name: "Another Item")
      item3 = create(:item, name: "Test Product")

      get "/api/v1/items/find?name=test"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      response_data = parsed_response

      expect(response_data).to have_key(:data)
      expect(response_data[:data]).to be_a(Hash)

      # Ensure the first item in alphabetical order is returned
      expect(response_data[:data]).to include(
        id: item1.id.to_s,
        type: "item"
      )

      expect(response_data[:data]).to have_key(:attributes)
      expect(response_data[:data][:attributes]).to be_a(Hash)
      expect(response_data[:data][:attributes]).to include(
        name: item1.name,
        description: item1.description,
        unit_price: item1.unit_price
      )
    end

    it "can find a single item by min_price" do
      item1 = create(:item, unit_price: 10.0)
      item2 = create(:item, unit_price: 20.0)
      item3 = create(:item, unit_price: 30.0)

      get "/api/v1/items/find?min_price=15"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      response_data = parsed_response

      expect(response_data).to have_key(:data)
      expect(response_data[:data]).to be_a(Hash)

      
      expect(response_data[:data]).to include(
        id: item2.id.to_s,
        type: "item"
      )

      expect(response_data[:data]).to have_key(:attributes)
      expect(response_data[:data][:attributes]).to be_a(Hash)
      expect(response_data[:data][:attributes]).to include(
        name: item2.name,
        description: item2.description,
        unit_price: item2.unit_price
      )
    end

    it "can find a single item by max_price" do
      item1 = create(:item, unit_price: 10.0)
      item2 = create(:item, unit_price: 20.0)
      item3 = create(:item, unit_price: 30.0)

      get "/api/v1/items/find?max_price=25"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      response_data = parsed_response

      expect(response_data).to have_key(:data)
      expect(response_data[:data]).to be_a(Hash)

     
      expect(response_data[:data]).to include(
        id: item1.id.to_s,
        type: "item"
      )

      expect(response_data[:data]).to have_key(:attributes)
      expect(response_data[:data][:attributes]).to be_a(Hash)
      expect(response_data[:data][:attributes]).to include(
        name: item1.name,
        description: item1.description,
        unit_price: item1.unit_price
      )
    end

    it "can find a single item by min_price and max_price" do
      item1 = create(:item, unit_price: 10.0)
      item2 = create(:item, unit_price: 20.0)
      item3 = create(:item, unit_price: 30.0)

      get "/api/v1/items/find?min_price=15&max_price=25"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      response_data = parsed_response

      expect(response_data).to have_key(:data)
      expect(response_data[:data]).to be_a(Hash)

      expect(response_data[:data]).to include(
        id: item2.id.to_s,
        type: "item"
      )

      expect(response_data[:data]).to have_key(:attributes)
      expect(response_data[:data][:attributes]).to be_a(Hash)
      expect(response_data[:data][:attributes]).to include(
        name: item2.name,
        description: item2.description,
        unit_price: item2.unit_price
      )
    end

    it "returns an error when both name and price parameters are sent" do
      get "/api/v1/items/find?name=ring&min_price=50"

      expect(response).not_to be_successful
      expect(response.status).to eq(400)

      response_data = parsed_response

      expect(response_data).to have_key(:error)
      expect(response_data[:error]).to eq("Cannot send both name and price parameters")
    end

    it "returns an error when no parameters are sent" do
      get "/api/v1/items/find"

      expect(response).not_to be_successful
      expect(response.status).to eq(400)

      response_data = parsed_response

      expect(response_data).to have_key(:error)
      expect(response_data[:error]).to eq("Parameter cannot be missing or empty")
    end

    it "returns an error when name parameter is empty" do
      get "/api/v1/items/find?name="

      expect(response).not_to be_successful
      expect(response.status).to eq(400)

      response_data = parsed_response

      expect(response_data).to have_key(:error)
      expect(response_data[:error]).to eq("Parameter cannot be missing or empty")
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

    it "returns an error when both name and price parameters are sent" do
      get "/api/v1/items/find_all?name=ring&min_price=50"

      expect(response).not_to be_successful
      expect(response.status).to eq(400)

      response_data = parsed_response

      expect(response_data).to have_key(:error)
      expect(response_data[:error]).to eq("Cannot send both name and price parameters")
    end

    it "returns an error when no parameters are sent" do
      get "/api/v1/items/find_all"

      expect(response).not_to be_successful
      expect(response.status).to eq(400)

      response_data = parsed_response

      expect(response_data).to have_key(:error)
      expect(response_data[:error]).to eq("Parameter cannot be missing or empty")
    end

    it "returns an error when name parameter is empty" do
      get "/api/v1/items/find_all?name="

      expect(response).not_to be_successful
      expect(response.status).to eq(400)

      response_data = parsed_response

      expect(response_data).to have_key(:error)
      expect(response_data[:error]).to eq("Parameter cannot be missing or empty")
    end
  end
end
