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
        merchant1 = create(:merchant)
        merchant2 = create(:merchant)
        merchant3 = create(:merchant)
        create(:invoice, merchant: merchant1, status: "returned")
        create(:invoice, merchant: merchant2, status: "returned")
        create(:invoice, merchant: merchant3, status: "shipped")

        get "/api/v1/merchants?status=returned"

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
        expect(response_merchants[1][:attributes][:name]).to eq(merchant2.name)
      end

      it "successfully returns merchant list with item count" do
        merchant1 = create(:merchant)
        merchant2 = create(:merchant)
        create_list(:item, 25, merchant: merchant1)
        create_list(:item, 30, merchant: merchant2)

        get "/api/v1/merchants?count=true"

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

          expect(attributes).to have_key(:item_count)
          expect(attributes[:item_count]).to be_a(Integer)
        end

        item_counts = response_merchants.map do |merchant|
          merchant[:attributes][:item_count]
        end
        expect(item_counts.sort).to eq([25, 30])
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
        merchant1 = create(:merchant, name: "Logan's Store")
        merchant2 = create(:merchant, name: "Alec's Store")
        merchant3 = create(:merchant, name: "Logan's Shop")

        get "/api/v1/merchants/find?name=log"

        expect(response).to be_successful
        expect(response.status).to eq(200)

        response_data = parsed_response

        expect(response_data).to have_key(:data)
        expect(response_data[:data]).to be_a(Hash)

        # Ensure the first merchant in alphabetical order is returned
        expected_merchant = [merchant2, merchant3, merchant1].sort_by(&:name).first
        expect(response_data[:data][:id].to_s.force_encoding("UTF-8")).to eq(expected_merchant.id.to_s.force_encoding("UTF-8"))
        expect(response_data[:data][:type]).to eq("merchant")
        expect(response_data[:data][:attributes][:name]).to eq(expected_merchant.name)
      end

      it "will gracefully handle find if the merchant name fragment is not found" do
        get "/api/v1/merchants/find?name=nonexistent"

        expect(response).to have_http_status(:not_found)

        response_data = parsed_response

        expect(response_data).to have_key(:errors)
        expect(response_data[:errors]).to eq(["404"])
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

  describe "GET /api/v1/merchants/sorted" do
    it "returns merchants sorted by name in alphabetical order" do
      merchant1 = create(:merchant, name: "Zeta Store")
      merchant2 = create(:merchant, name: "Alpha Store")
      merchant3 = create(:merchant, name: "Beta Store")

      get "/api/v1/merchants/sorted"

      expect(response).to be_successful
      expect(response.status).to eq(200)

      response_data = JSON.parse(response.body, symbolize_names: true)
      expect(response_data).to have_key(:data)
      expect(response_data[:data]).to be_an(Array)

      response_merchants = response_data[:data]
      expect(response_merchants.length).to eq(3)
      expect(response_merchants[0][:attributes][:name]).to eq("Alpha Store")
      expect(response_merchants[1][:attributes][:name]).to eq("Beta Store")
      expect(response_merchants[2][:attributes][:name]).to eq("Zeta Store")
    end

    context "error handling" do
      it "returns a 404 error when Merchant.order fails" do
        allow(Merchant).to receive(:order).and_raise(ActiveRecord::RecordNotFound.new("Merchant not found"))
        get "/api/v1/merchants/sorted"
        expect(response).not_to be_successful
        expect(response.status).to eq(404)
        body = JSON.parse(response.body, symbolize_names: true)
        expect(body[:errors].first).to eq("404")
      end
    end
  end

  describe "Non-RESTful search endpoints for Merchants" do
    context "with faker-generated merchant name" do
      it "finds the merchant using a substring of the generated name" do
        generated_name = Faker::Commerce.vendor
        merchant = create(:merchant, name: generated_name)
        substring = generated_name[0, 3].downcase
        get "/api/v1/merchants/find", params: {name: substring}
        body = parsed_response
        expect(body[:data][:attributes][:name]).to eq(merchant.name)
      end

      it "returns an array of matching merchants using Faker values" do
        generated_name1 = Faker::Commerce.vendor
        generated_name2 = Faker::Commerce.vendor
        create(:merchant, name: generated_name1)
        create(:merchant, name: generated_name2)
        # Use a substring from one of the generated names
        substring = generated_name1[0, 2].downcase
        get "/api/v1/merchants/find_all", params: {name: substring}
        body = parsed_response
        expect(body[:data]).to be_an(Array)
        expect(body[:data].length).to be >= 1
        body[:data].each do |merch|
          expect(merch[:attributes][:name].downcase).to include(substring)
        end
      end
    end

    context "Additional tests for non‑RESTful merchants search" do
      it "passes a valid name query and returns a merchant" do
        merchant = create(:merchant, name: "Acme Corp")
        get "/api/v1/merchants/find", params: {name: "Acme"}
        body = parsed_response
        expect(body[:data][:attributes][:name]).to eq(merchant.name)
      end

      it "returns not found when no merchant matches the valid name query" do
        get "/api/v1/merchants/find", params: {name: "nonexistent"}
        expect(response).to have_http_status(:not_found)
      end

      it "returns bad_request when missing parameters for find" do
        get "/api/v1/merchants/find", params: {}
        expect(response).to have_http_status(:bad_request)
      end

      # For find_all, when no records are found, an empty array is returned.
      it "returns an empty array for find_all when no merchant matches" do
        get "/api/v1/merchants/find_all", params: {name: "nonexistent"}
        body = parsed_response
        expect(body[:data]).to eq([])
      end
    end
  end
end
