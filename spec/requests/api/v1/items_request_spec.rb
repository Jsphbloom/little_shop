require "rails_helper"

RSpec.describe "Items API", type: :request do
  describe "DELETE /api/v1/items/:id" do
    let!(:merchant) { Merchant.create(name: "Test Merchant") }
    let!(:item) { Item.create(name: "Test Item", description: "Sample", unit_price: 10.0, merchant_id: merchant.id) }

    context "when the item exists" do
      it "deletes the item" do
        delete "/api/v1/items/#{item.id}"
        expect(response).to have_http_status(:no_content)
        expect(Item.find_by(id: item.id)).to be_nil
      end
    end

    context "when the item does not exist" do
      it "returns not found" do
        delete "/api/v1/items/0"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
