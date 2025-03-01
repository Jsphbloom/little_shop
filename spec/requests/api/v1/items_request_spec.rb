require "rails_helper"
RSpec.describe "Items API", type: :request do
  def parsed_response
    JSON.parse(response.body, symbolize_names: true)
  end

  describe "endpoints" do
    describe "GET /api/v1/items" do
      it "can return an index of items" do
        create_list(:item, 3)
        get "/api/v1/items"

        expect(response).to be_successful
        expect(response.status).to eq(200)

        response_data = parsed_response

        expect(response_data).to have_key(:data)
        expect(response_data[:data]).to be_an(Array)

        response_items = response_data[:data]

        expect(response_items.length).to eq(3)

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
      end

      it "can sort items by price" do
        item1 = create(:item, unit_price: 2.0)
        item2 = create(:item, unit_price: 3.0)
        item3 = create(:item, unit_price: 4.0)
        item4 = create(:item, unit_price: 1.0)
        get "/api/v1/items?sorted=price"

        expect(response).to be_successful
        expect(response.status).to eq(200)

        response_data = parsed_response

        expect(response_data).to have_key(:data)
        expect(response_data[:data]).to be_an(Array)

        response_items = response_data[:data]

        expect(response_items.length).to eq(4)

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

        expect(response_data[:data][0][:attributes][:name]).to eq(item4.name)
        expect(response_data[:data][1][:attributes][:name]).to eq(item1.name)
        expect(response_data[:data][2][:attributes][:name]).to eq(item2.name)
        expect(response_data[:data][3][:attributes][:name]).to eq(item3.name)
      end
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

        expect(response_data).to have_key(:data)
        expect(response_data[:data]).to be_a(Hash)

        response_item = response_data[:data]

        expect(response_item).to have_key(:id)
        expect(response_item[:id]).to be_a(String)

        expect(response_item).to have_key(:type)
        expect(response_item[:type]).to eq("item")

        expect(response_item).to have_key(:attributes)
        expect(response_item[:attributes]).to be_a(Hash)
        expect(response_item[:attributes]).to include(
          name: item.name,
          description: item.description,
          unit_price: item.unit_price
        )
      end
    end

    describe "POST /api/v1/items/" do
      it "can create new items" do
        create(:merchant)
        item_params = {
          name: Faker::Commerce.product_name,
          description: Faker::Commerce.material,
          unit_price: Faker::Commerce.price,
          merchant_id: Merchant.last.id
        }
        headers = {"CONTENT_TYPE" => "application/json"}

        post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

        expect(response).to be_successful
        expect(response.status).to eq(201)

        created_item = Item.last

        expect(created_item).to have_attributes(item_params)

        response_data = parsed_response

        expect(response_data[:data]).to include(
          id: created_item.id.to_s,
          type: "item"
        )

        expect(response_data).to have_key(:data)
        expect(response_data[:data]).to be_a(Hash)

        response_item = response_data[:data]

        expect(response_item).to have_key(:id)
        expect(response_item[:id]).to be_a(String)

        expect(response_item).to have_key(:type)
        expect(response_item[:type]).to eq("item")

        expect(response_item).to have_key(:attributes)
        expect(response_item[:attributes]).to be_a(Hash)
        expect(response_data[:data][:attributes]).to include(item_params)
      end
    end

    describe "PUT /api/v1/items/:id" do
      it "can update an existing item" do
        item = create(:item)
        create(:merchant)

        item_params = {
          name: Faker::Commerce.product_name,
          description: Faker::Commerce.material,
          unit_price: Faker::Commerce.price,
          merchant_id: Merchant.last.id
        }
        headers = {"CONTENT_TYPE" => "application/json"}

        put "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item: item_params)

        expect(response).to be_successful
        expect(response.status).to eq(200)

        item = Item.find(item.id)

        expect(item).to have_attributes(item_params)

        response_data = parsed_response

        expect(response_data[:data]).to include(
          id: item.id.to_s,
          type: "item"
        )

        expect(response_data).to have_key(:data)
        expect(response_data[:data]).to be_a(Hash)

        response_item = response_data[:data]

        expect(response_item).to have_key(:id)
        expect(response_item[:id]).to be_a(String)

        expect(response_item).to have_key(:type)
        expect(response_item[:type]).to eq("item")

        expect(response_item).to have_key(:attributes)
        expect(response_item[:attributes]).to be_a(Hash)
        expect(response_data[:data][:attributes]).to include(item_params)
        expect(item.name).to eq(item_params[:name])
        expect(item.description).to eq(item_params[:description])
        expect(item.unit_price).to eq(item_params[:unit_price])
        expect(item.merchant_id).to eq(item_params[:merchant_id])
      end

      it "can update an existing item with only partial data" do
        item = create(:item)
        create(:merchant)

        item_params = {unit_price: Faker::Commerce.price}
        headers = {"CONTENT_TYPE" => "application/json"}

        put "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item: item_params)

        expect(response).to be_successful
        expect(response.status).to eq(200)

        item = Item.find(item.id)

        expect(item).to have_attributes(item_params)

        response_data = parsed_response

        expect(response_data[:data]).to include(
          id: item.id.to_s,
          type: "item"
        )

        expect(response_data).to have_key(:data)
        expect(response_data[:data]).to be_a(Hash)

        response_item = response_data[:data]

        expect(response_item).to have_key(:id)
        expect(response_item[:id]).to be_a(String)

        expect(response_item).to have_key(:type)
        expect(response_item[:type]).to eq("item")

        expect(response_item).to have_key(:attributes)
        expect(response_item[:attributes]).to be_a(Hash)
        expect(response_data[:data][:attributes]).to include(item_params)
        expect(item.unit_price).to eq(item_params[:unit_price])
      end
    end

    describe "DELETE /api/v1/items/:id" do
      it "deletes an existing item created in the before block" do
        item = create(:item)

        delete "/api/v1/items/#{item.id}"

        expect(response).to be_successful
        expect(response.status).to eq(204)

        expect(Item.find_by(id: item.id)).to be_nil
      end
    end
  end

  describe "sad paths" do
    it "will gracefully handle get with a nonexistent item id" do
      get "/api/v1/items/8923987297"

      expect(response).not_to be_successful
      expect(response.status).to eq(404)

      response_data = parsed_response

      expect(response_data[:errors]).to eq(["404"])
      expect(response_data[:message]).to eq("Couldn't find Item with 'id'=8923987297")
    end

    it "will gracefully handle get with an invalid item id" do
      get "/api/v1/items/string-instead-of-integer"

      expect(response).not_to be_successful
      expect(response.status).to eq(404)

      response_data = parsed_response

      expect(response_data[:errors]).to eq(["404"])
      expect(response_data[:message]).to eq("Couldn't find Item with 'id'=string-instead-of-integer")
    end

    it "will gracefully handle create if name isn't provided" do
      post "/api/v1/items", headers: headers, params: JSON.generate({})

      expect(response).not_to be_successful
      expect(response.status).to eq(422)

      response_data = parsed_response

      expect(response_data[:errors].first).to eq("422")
      expect(response_data[:message]).to eq("param is missing or the value is empty: item")
    end

    it "will gracefully handle update if params aren't provided" do
      item = create(:item)

      put "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item: {})

      expect(response).not_to be_successful
      expect(response.status).to eq(422)

      response_data = parsed_response

      expect(response_data[:errors].first).to eq("422")
      expect(response_data[:message]).to eq("param is missing or the value is empty: item")
    end

    it "will gracefully handle update with a nonexistent item id" do
      create(:merchant)

      put "/api/v1/items/12435678912354", headers: headers, params: JSON.generate(item: {
        name: Faker::Commerce.product_name,
        description: Faker::Commerce.material,
        unit_price: Faker::Commerce.price,
        merchant_id: Merchant.last.id
      })

      expect(response).not_to be_successful
      expect(response.status).to eq(404)

      response_data = parsed_response

      expect(response_data[:errors].first).to eq("404")
      expect(response_data[:message]).to eq("Couldn't find Item with 'id'=12435678912354")
    end

    it "will gracefully handle update with a nonexistent merchant id" do
      item = create(:item)

      headers = {"CONTENT_TYPE" => "application/json"}

      put "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item: {merchant_id: 999999999999})

      expect(response).not_to be_successful
      expect(response.status).to eq(404)

      response_data = parsed_response

      expect(response_data[:errors].first).to eq("404")
      expect(response_data[:message]).to eq("Couldn't find Merchant with 'id'=999999999999")
    end

    it "will gracefully handle update with invalid merchant id" do
      item = create(:item)

      headers = {"CONTENT_TYPE" => "application/json"}

      put "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item: {merchant_id: "string-instead-of-integer"})

      expect(response).not_to be_successful
      expect(response.status).to eq(404)

      response_data = parsed_response

      expect(response_data[:errors].first).to eq("404")
      expect(response_data[:message]).to eq("Couldn't find Merchant with 'id'=string-instead-of-integer")
    end

    it "will gracefully handle delete with a nonexistent item" do
      delete "/api/v1/items/0"

      expect(response).not_to be_successful
      expect(response.status).to eq(404)

      response_data = parsed_response

      expect(response_data[:errors].first).to eq("404")
      expect(response_data[:message]).to eq("Couldn't find Item with 'id'=0")
    end
  end

  describe "Non-RESTful search endpoints for Items" do
    context "with faker-generated item name" do
      it "finds the item using a substring of the generated name" do
        generated_name = Faker::Commerce.product_name
        item = create(:item, name: generated_name)
        substring = generated_name[0, 3].downcase
        get "/api/v1/items/find", params: {name: substring}
        body = parsed_response
        expect(body[:data][:attributes][:name]).to eq(item.name)
      end

      it "returns an array of matching items using Faker values" do
        generated_name1 = Faker::Commerce.product_name
        generated_name2 = Faker::Commerce.product_name
        create(:item, name: generated_name1)
        create(:item, name: generated_name2)
        substring = generated_name1[0, 2].downcase
        get "/api/v1/items/find_all", params: {name: substring}
        body = parsed_response
        expect(body[:data]).to be_an(Array)
        expect(body[:data].length).to be >= 1
        body[:data].each do |it|
          expect(it[:attributes][:name].downcase).to include(substring)
        end
      end
    end
  end
end
