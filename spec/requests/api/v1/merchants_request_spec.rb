require "rails_helper"
# bundle exec rspec spec/requests/api/v1/merchants_request_spec.rb

RSpec.describe "Merchants API", type: :request do
  before do
    Merchant.destroy_all
    # Create dummy merchants with "s" prefix as instance variables
    @sMerchant1 = Merchant.create!(name: "Dummy Merchant 1")
    @sMerchant2 = Merchant.create!(name: "Dummy Merchant 2")
    @sMerchant3 = Merchant.create!(name: "Dummy Merchant 3")
  end

  def parsed_response
    JSON.parse(response.body, symbolize_names: true)
  end

  describe "GET /api/v1/merchants" do 
    it "can return a single merchant by id" do 
      merchant = create(:merchant)

      get "/api/v1/merchants/#{merchant.id}"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      response_data = parsed_response

      expect(response_data[:data]).to include(
        id: merchant.id.to_s,
        type: "merchant" 
      )

      expect(response_data[:data][:attributes]).to include(
        name: merchant.name
      )
    end

    it "returns a 404 if the merchant is not found" do
      get "/api/v1/merchants/0"

      expect(response).to have_http_status(:not_found)

      response_data = parsed_response
      expect(response_data[:error]).to eq("Merchant not found")
    end
  end
  
  describe "POST /api/v1/merchants" do
    it "can create a new merchant" do
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
    it "can update an existing merchant" do
      merchant = create(:merchant)

      new_name = Faker::Commerce.vendor until new_name != merchant.name && new_name

      merchant_params = {name: new_name}
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/merchants/#{merchant.id}", headers: headers, params: JSON.generate(merchant: merchant_params)

      expect(response).to be_successful

      merchant = Merchant.find(merchant.id)

      expect(merchant).to have_attributes(merchant_params)

      response_data = parsed_response

      expect(response_data[:data]).to include(
        id: merchant.id.to_s,
        type: "merchant"
      )

      expect(response_data[:data][:attributes]).to include(merchant_params)
      expect(merchant.name).to eq(new_name)
    end
  end

  describe "DELETE /api/v1/merchants/:id" do
    it "deletes an existing merchant created in the before block" do
      # Use sMerchant1 created in before block
      delete "/api/v1/merchants/#{@sMerchant1.id}"
      expect(response).to have_http_status(:no_content)
      expect(Merchant.find_by(id: @sMerchant1.id)).to be_nil
    end

    it "returns not found when deleting a non-existent merchant" do
      delete "/api/v1/merchants/0"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "sad paths" do
    it "will gracefully handle create if name isn't provided" do
      post "/api/v1/merchants", headers: headers, params: JSON.generate(merchant: {})

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

    it "will gracefully handle update if name isn't provided" do
      merchant = create(:merchant)

      patch "/api/v1/merchants/#{merchant.id}", headers: headers, params: JSON.generate(merchant: {})

      expect(response).not_to be_successful
      expect(response.status).to eq(400).or eq(404)
    end
  end
end
