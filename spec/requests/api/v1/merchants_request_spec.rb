require "rails_helper"
# rspec spec/requests/api/v1/merchants_request_spec.rb

RSpec.describe "Merchants API", type: :request do
  describe "DELETE /api/v1/merchants/:id" do
    let!(:merchant) { Merchant.create(name: "Test Merchant") }

    context "when the merchant exists" do
      it "deletes the merchant" do
        delete "/api/v1/merchants/#{merchant.id}"
        expect(response).to have_http_status(:no_content)
        expect(Merchant.find_by(id: merchant.id)).to be_nil
      end
    end

    context "when the merchant does not exist" do
      it "returns not found" do
        delete "/api/v1/merchants/0"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
