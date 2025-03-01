require "rails_helper"

RSpec.describe "Merchants API", type: :request do
  # Helper for parsing JSON responses.
  def parsed_response
    JSON.parse(response.body, symbolize_names: true)
  end

  describe "POST /api/v1/merchants" do
    it "creates a new merchant" do
      merchant_params = {name: Faker::Commerce.vendor}
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

  describe "PATCH /api/v1/merchants/:id" do
    it "updates an existing merchant" do
      merchant = create(:merchant)   # Using FactoryBot
      new_name = Faker::Commerce.vendor
      merchant_params = {name: new_name}
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/merchants/#{merchant.id}", headers: headers, params: JSON.generate(merchant: merchant_params)
      expect(response).to be_successful

      updated_merchant = Merchant.find(merchant.id)
      expect(updated_merchant).to have_attributes(merchant_params)

      response_data = parsed_response
      expect(response_data[:data]).to include(
        id: updated_merchant.id.to_s,
        type: "merchant"
      )
      expect(response_data[:data][:attributes]).to include(merchant_params)
    end
  end

  describe "DELETE /api/v1/merchants/:id" do
    it "deletes an existing merchant" do
      merchant = create(:merchant)
      delete "/api/v1/merchants/#{merchant.id}"
      expect(response).to have_http_status(:no_content)
      expect(Merchant.find_by(id: merchant.id)).to be_nil
    end

    it "returns not found when deleting a non-existent merchant" do
      delete "/api/v1/merchants/0"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "sad paths" do
    it "handles create with missing name gracefully" do
      headers = {"CONTENT_TYPE" => "application/json"}
      post "/api/v1/merchants", headers: headers, params: JSON.generate(merchant: {})
      expect(response).not_to be_successful
      expect(response.status).to eq(422)

      response_data = parsed_response
      expect(response_data).to have_key(:message)
      expect(response_data[:message]).to eq("param is missing or the value is empty: merchant")
      expect(response_data).to have_key(:errors)
      expect(response_data[:errors]).to include("422")
    end

    it "handles update with missing name gracefully" do
      merchant = create(:merchant)
      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/merchants/#{merchant.id}", headers: headers, params: JSON.generate(merchant: {})
      expect(response).not_to be_successful
      # Expect a 422 since missing parameters trigger that response.
      expect(response.status).to eq(422)
    end
  end

  describe "GET /api/v1/merchants/find" do
    it "can find a single merchant by name fragment" do
      merchant = create(:merchant, name: "Logan's Store")
      create(:merchant, name: "Alec's Store")
      create(:merchant, name: "Logan's Shop")

      get "/api/v1/merchants/find?name=log"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      response_data = parsed_response

      expect(response_data).to have_key(:data)
      expect(response_data[:data]).to be_a(Hash)

      expect(response_data[:data]).to include(
        id: merchant.id.to_s,
        type: "merchant"
      )

      expect(response_data[:data]).to have_key(:attributes)
      expect(response_data[:data][:attributes]).to be_a(Hash)
      expect(response_data[:data][:attributes]).to include(
        name: merchant.name
      )
    end
  end

  describe "GET /api/v1/merchants/find_all" do
    it "can find all merchants by name fragment" do
      merchant1 = create(:merchant, name: "Logan's Store")
      merchant2 = create(:merchant, name: "Alec's Store")
      merchant3 = create(:merchant, name: "Logan's Shop")

      get "/api/v1/merchants/find_all?name=log"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      response_data = parsed_response

      expect(response_data).to have_key(:data)
      expect(response_data[:data]).to be_an(Array)

      response_merchants = response_data[:data]

      expect(response_merchants.length).to eq(2)

      response_merchants.each do |merchant|
        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_a(String)

        expect(merchant).to have_key(:type)
        expect(merchant[:type]).to eq("merchant")

        expect(merchant).to have_key(:attributes)
        expect(merchant[:attributes]).to be_a(Hash)

        attributes = merchant[:attributes]

        expect(attributes).to have_key(:name)
        expect(attributes[:name]).to be_a(String)
      end

      expect(response_merchants[0][:attributes][:name]).to eq(merchant1.name)
      expect(response_merchants[1][:attributes][:name]).to eq(merchant3.name)
    end
  end
end