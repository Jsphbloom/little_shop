require "rails_helper"

describe "Items API", type: :request do
  before do
    create(:merchant)
  end

  def parsed_response
    JSON.parse(response.body, symbolize_names: true)
  end

  describe "create" do
    it "can create a new item" do
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

      # require "pry"
      # binding.pry

      expect(created_item).to have_attributes(item_params)

      response_data = parsed_response

      expect(response_data[:data]).to include(
        id: created_item.id.to_s,
        type: "item"
      )

      expect(response_data[:data][:attributes]).to include(item_params)
    end
  end

  describe "update" do
    it "can update an existing item" do
      item = create(:item)

      item_params = {
        name: Faker::Commerce.product_name,
        description: Faker::Commerce.material,
        unit_price: Faker::Commerce.price,
        merchant_id: Merchant.all.sample.id
      }
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item: item_params)

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

      patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item: {})

      expect(response).not_to be_successful
      expect(response.status).to eq(400).or eq(404)
    end
  end
end
