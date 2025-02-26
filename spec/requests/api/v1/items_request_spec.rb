require "rails_helper"

# bundle exec rspec spec/requests/api/v1/items_request_spec.rb

RSpec.describe "Items API", type: :request do
  before do
    Merchant.destroy_all
    Item.destroy_all
    # Create dummy merchants for association with "s" prefix
    @sMerchant1 = Merchant.create!(name: "Dummy Merchant 1")
    @sMerchant2 = Merchant.create!(name: "Dummy Merchant 2")
    @sMerchant3 = Merchant.create!(name: "Dummy Merchant 3")
    # Create dummy items for DELETE testing
    @sItem1 = Item.create!(
      name: "Dummy Item 1",
      description: "Dummy description 1",
      unit_price: 10.0,
      merchant: @sMerchant1
    )
    Item.create!(
      name: "Dummy Item 2",
      description: "Dummy description 2",
      unit_price: 20.0,
      merchant: @sMerchant2
    )
    Item.create!(
      name: "Dummy Item 3",
      description: "Dummy description 3",
      unit_price: 30.0,
      merchant: @sMerchant3
    )
  end

  describe "POST /api/v1/items" do
    it "creates a new item using the endpoint" do
      # Create a merchant via the endpoint to associate with the new item.
      post "/api/v1/merchants", params: {merchant: {name: "Item Merchant"}}
      merchant = JSON.parse(response.body, symbolize_names: true)

      post "/api/v1/items", params: {
        item: {
          name: "Dummy Item 4",
          description: "Dummy description 1",
          unit_price: 10.0,
          merchant_id: merchant[:data][:id]
        }
      }
      expect(response).to have_http_status(:created).or have_http_status(:ok)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:data][:attributes][:name]).to eq("Dummy Item 4")
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
end
