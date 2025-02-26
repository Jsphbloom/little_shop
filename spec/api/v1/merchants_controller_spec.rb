require "rails_helper"

describe "Merchants API", type: :request do
  def parsed_response
    JSON.parse(response.body, symbolize_names: true)
  end

  describe "create" do
    it "can create a new merchant" do
      merchant_params = {name: "merchant_name"}
      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/merchants", headers: headers, params: JSON.generate(merchant: merchant_params)

      expect(response).to be_successful

      created_merchant = Merchant.last

      expect(created_merchant).to have_attributes(merchant_params)

      response_data = parsed_response

      expect(response_data[:data]).to include(
        id: created_merchant.id.to_s,
        type: "merchant"
      )

      expect(response_data[:data][:attributes]).to include(merchant_params)
    end
  end

  describe "sad paths" do
    it "will gracefully handle if name isn't provided" do
      post "/api/v1/merchants", headers: headers, params: JSON.generate({})

      expect(response).not_to be_successful
      expect(response.status).to eq(422)

      response_data = parsed_response

      expect(response_data).to have_key(:message)
      expect(response_data[:message]).to be_a(String)
      expect(response_data[:message]).to eq("param is missing or the value is empty: merchant")

      expect(response_data).to have_key(:errors)
      expect(response_data[:errors]).to be_a(Array)
      expect(response_data[:errors].first).to eq("422")
    end
  end
end
