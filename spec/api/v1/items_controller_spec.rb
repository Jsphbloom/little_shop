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
        name: "value1",
        description: "value2",
        unit_price: 100.99,
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
  end
end
