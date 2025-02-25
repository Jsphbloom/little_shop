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
end
