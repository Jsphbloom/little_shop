require "rails_helper"
RSpec.describe "Items API", type: :request do
  before do
    Merchant.destroy_all
    Item.destroy_all
    @sMerchant1 = create(:merchant, name: Faker::Company.unique.name)
    @sMerchant2 = create(:merchant, name: Faker::Company.unique.name)
    @sMerchant3 = create(:merchant, name: Faker::Company.unique.name)
    @sItem1 = create(:item,
      name: Faker::Commerce.product_name,
      description: Faker::Commerce.material,
      unit_price: Faker::Commerce.price,
      merchant: @sMerchant1)
    @sItem2 = create(:item,
      name: Faker::Commerce.product_name,
      description: Faker::Commerce.material,
      unit_price: Faker::Commerce.price,
      merchant: @sMerchant2)
    @sItem3 = create(:item,
      name: Faker::Commerce.product_name,
      description: Faker::Commerce.material,
      unit_price: Faker::Commerce.price,
      merchant: @sMerchant3)
  end

  def parsed_response
    JSON.parse(response.body, symbolize_names: true)
  end

  describe "GET /api/v1/items/:id" do
    it "can fetch a single existing item by id" do
      item = create(:item)
      get "/api/v1/items/#{item.id}"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      response_data = parsed_response

      expect(response_data[:data]).to include(
        id: item.id.to_s,
        type: "item"
      )

      expect(response_data[:data][:attributes]).to include(
        name: item.name,
        description: item.description,
        unit_price: item.unit_price
      )
    end

    it "returns a 404 if the item is not found" do
      get "/api/v1/items/0"

      expect(response).to have_http_status(:not_found)

      response_data = parsed_response
      expect(response_data[:error]).to eq("Item not found")
    end
  end

  describe "GET /api/v1/items" do
    it "can return an index of items" do
      get "/api/v1/items"

      expect(response).to be_successful

      response_data = parsed_response

      expect(response_data[:data].count).to eq(3)
      expect(response_data[:data][0][:attributes][:name]).to eq(@sItem1.name)
      expect(response_data[:data][0][:attributes][:merchant_id]).to eq(@sMerchant1.id)
      expect(response_data[:data][1][:attributes][:name]).to eq(@sItem2.name)
      expect(response_data[:data][1][:attributes][:merchant_id]).to eq(@sMerchant2.id)
      expect(response_data[:data][2][:attributes][:name]).to eq(@sItem3.name)
      expect(response_data[:data][2][:attributes][:merchant_id]).to eq(@sMerchant3.id)
    end

    it "can sort items by price" do
      @sItem4 = Item.create!(
      name: "Dummy Item 4",
      description: "Dummy description 4",
      unit_price: 1.0,
      merchant: @sMerchant1
    )
      get "/api/v1/items?sorted=price"
      expect(response).to be_successful
      
      response_data = parsed_response

      expect(response_data[:data].count).to eq(4)
      expect(response_data[:data][0][:attributes][:name]).to eq("Dummy Item 4")
      expect(response_data[:data][1][:attributes][:name]).to eq("Dummy Item 1")
      expect(response_data[:data][2][:attributes][:name]).to eq("Dummy Item 2")
    end
  end

  describe "create" do
    it "POST /api/v1/items/" do
      item_params = {
        name: Faker::Commerce.product_name,
        description: Faker::Commerce.material,
        unit_price: Faker::Commerce.price,
        merchant_id: Merchant.last.id
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
    it "can update an existing item" do
      item = create(:item)

      item_params = {
        name: Faker::Commerce.product_name,
        description: Faker::Commerce.material,
        unit_price: Faker::Commerce.price,
        merchant_id: Merchant.all.sample.id
      }
      headers = {"CONTENT_TYPE" => "application/json"}

      put "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item: item_params)

      expect(response).to be_successful

      item = Item.find(item.id)

      expect(item).to have_attributes(item_params)

      response_data = parsed_response

      expect(response_data[:data]).to include(
        id: item.id.to_s,
        type: "item"
      )

      expect(response_data[:data][:attributes]).to include(item_params)
      expect(item.name).to eq(item_params[:name])
      expect(item.description).to eq(item_params[:description])
      expect(item.unit_price).to eq(item_params[:unit_price])
      expect(item.merchant_id).to eq(item_params[:merchant_id])
    end
  end

  describe "DELETE /api/v1/items/:id" do
    it "deletes an existing item created in the before block" do
      delete "/api/v1/items/#{@sItem1.id}"
      expect(response).to have_http_status(:no_content)
      expect(Item.find_by(id: @sItem1.id)).to be_nil
    end

    it "returns not found when deleting a non-existent item" do
      delete "/api/v1/items/0"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "sad paths" do
    it "will gracefully handle if name isn't provided" do
      post "/api/v1/items", headers: headers, params: JSON.generate({})

      expect(response).not_to be_successful
      expect(response.status).to eq(422)

      response_data = parsed_response

      expect(response_data).to have_key(:message)
      expect(response_data[:message]).to be_a(String)
      expect(response_data[:message]).to eq("param is missing or the value is empty: item")

      expect(response_data).to have_key(:errors)
      expect(response_data[:errors]).to be_a(Array)
      expect(response_data[:errors].first).to eq("422")
    end

    it "will gracefully handle update if params aren't provided" do
      item = create(:item)

      put "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item: {})

      expect(response).not_to be_successful
      expect(response.status).to eq(422)
    end

    it "will gracefully handle update with invalid merchant id" do
      item = create(:item)

      put "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item: {merchant_id: 999999999999})

      expect(response).not_to be_successful
      expect(response.status).to eq(422)
    end
  end
end
