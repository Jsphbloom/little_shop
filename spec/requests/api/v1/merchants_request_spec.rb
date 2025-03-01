require "rails_helper"

RSpec.describe "Merchants API", type: :request do
  def parsed_response
    JSON.parse(response.body, symbolize_names: true)
  end

  describe "endpoints" do
    describe "GET /api/v1/merchants" do
      it "can return an index of merchants" do
        create_list(:merchant, 3)

        get "/api/v1/merchants"

        expect(response).to be_successful
        expect(response.status).to eq(200)

        response_data = parsed_response

        expect(response_data).to have_key(:data)
        expect(response_data[:data]).to be_an(Array)

        response_merchants = response_data[:data]

        expect(response_merchants.length).to eq(3)

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
      end

      it "can sort merchants by newest to oldest" do
        merchant1 = create(:merchant)
        merchant2 = create(:merchant)
        merchant3 = create(:merchant)

        get "/api/v1/merchants?sorted=age"

        expect(response).to be_successful
        expect(response.status).to eq(200)

        response_data = parsed_response

        expect(response_data).to have_key(:data)
        expect(response_data[:data]).to be_an(Array)

        response_merchants = response_data[:data]

        expect(response_merchants.length).to eq(3)

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
        expect(response_merchants[0][:attributes][:name]).to eq(merchant3.name)
        expect(response_merchants[1][:attributes][:name]).to eq(merchant2.name)
        expect(response_merchants[2][:attributes][:name]).to eq(merchant1.name)
      end

      it "successfully get merchants with invoice status of returned" do
        get "/api/v1/merchants?status=returned"
        expect(response).to be_successful
      end

      it "successfully returns merchant list with item count" do
        get "/api/v1/merchants?count=true"
        expect(response).to be_successful
      end
    end

    describe "GET /api/v1/merchants" do
      it "can return a single merchant by id" do
        merchant = create(:merchant)

        get "/api/v1/merchants/#{merchant.id}"

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

    describe "GET /api/v1/merchants/find?" do
      it "can return a single merchant by name fragment" do
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

    describe "POST /api/v1/merchants" do
      it "can create a new merchant" do
        merchant_params = {name: Faker::Commerce.vendor}
        headers = {"CONTENT_TYPE" => "application/json"}

        post "/api/v1/merchants", headers: headers, params: JSON.generate(merchant: merchant_params)

        expect(response).to be_successful
        expect(response.status).to eq(201)

        created_merchant = Merchant.last

        expect(created_merchant).to have_attributes(merchant_params)

        response_data = parsed_response

        expect(response_data[:data]).to include(
          id: created_merchant.id.to_s,
          type: "merchant"
        )

        expect(response_data[:data]).to have_key(:attributes)
        expect(response_data[:data][:attributes]).to be_a(Hash)
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
        expect(response.status).to eq(200)

        merchant = Merchant.find(merchant.id)

        expect(merchant).to have_attributes(merchant_params)

        response_data = parsed_response

        expect(response_data[:data]).to include(
          id: merchant.id.to_s,
          type: "merchant"
        )

        expect(response_data[:data]).to have_key(:attributes)
        expect(response_data[:data][:attributes]).to be_a(Hash)
        expect(response_data[:data][:attributes]).to include(merchant_params)
        expect(merchant.name).to eq(new_name)
      end
    end

    describe "DELETE /api/v1/merchants/:id" do
      it "deletes an existing merchant created in the before block" do
        merchant = create(:merchant)

        delete "/api/v1/merchants/#{merchant.id}"

        expect(response).to be_successful
        expect(response.status).to eq(204)

        expect(Merchant.find_by(id: merchant.id)).to be_nil
      end
    end
  end

  describe "sad paths" do
    it "will gracefully handle get with a nonexistent merchant id" do
      get "/api/v1/merchants/0"

      expect(response).not_to be_successful
      expect(response.status).to eq(404)

      response_data = parsed_response

      expect(response_data[:errors]).to eq(["404"])
      expect(response_data[:message]).to eq("Couldn't find Merchant with 'id'=0")
    end

    it "will gracefully handle find if the merchant name fragment is not found" do
      get "/api/v1/merchants/find?name=zzz"

      expect(response).not_to be_successful
      expect(response.status).to eq(404)

      response_data = parsed_response

      expect(response_data[:errors]).to eq(["404"])
      expect(response_data[:message]).to eq("Merchant not found")
    end

    it "will gracefully handle create if name isn't provided" do
      post "/api/v1/merchants", headers: headers, params: JSON.generate(merchant: {})

      expect(response).not_to be_successful
      expect(response.status).to eq(422)

      response_data = parsed_response

      expect(response_data[:errors].first).to eq("422")
      expect(response_data[:message]).to eq("param is missing or the value is empty: merchant")
    end

    it "will gracefully handle update if name isn't provided" do
      merchant = create(:merchant)

      patch "/api/v1/merchants/#{merchant.id}", headers: headers, params: JSON.generate(merchant: {})

      expect(response).not_to be_successful
      expect(response.status).to eq(422)

      response_data = parsed_response

      expect(response_data[:errors].first).to eq("422")
      expect(response_data[:message]).to eq("param is missing or the value is empty: merchant")
    end

    it "will gracefully handle update with nonexistent id" do
      patch "/api/v1/merchants/99999999", headers: headers, params: JSON.generate(merchant: {})

      expect(response).not_to be_successful
      expect(response.status).to eq(404)

      response_data = parsed_response

      expect(response_data[:errors].first).to eq("404")
      expect(response_data[:message]).to eq("Couldn't find Merchant with 'id'=99999999")
    end

    it "will gracefully handle update with invalid id" do
      patch "/api/v1/merchants/string-instead-of-integer", headers: headers, params: JSON.generate(merchant: {})

      expect(response).not_to be_successful
      expect(response.status).to eq(404)

      response_data = parsed_response

      expect(response_data[:errors].first).to eq("404")
      expect(response_data[:message]).to eq("Couldn't find Merchant with 'id'=string-instead-of-integer")
    end

    it "returns not found when deleting a non-existent merchant" do
      delete "/api/v1/merchants/0"

      expect(response).not_to be_successful
      expect(response.status).to eq(404)

      response_data = parsed_response

      expect(response_data[:errors].first).to eq("404")
      expect(response_data[:message]).to eq("Couldn't find Merchant with 'id'=0")
    end
  end
end
