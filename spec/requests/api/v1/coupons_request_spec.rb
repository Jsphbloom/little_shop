require "rails_helper"

RSpec.describe "Coupons API", type: :request do
  def parsed_response
    JSON.parse(response.body, symbolize_names: true)
  end

  describe "endpoints" do
    describe "GET /api/v1/coupons" do
      it "can return an index of coupons" do
        merchants = create_list(:merchant, 5)
        merchants.each do |merchant|
          create_list(:coupon, 4, merchant: merchant)
        end

        get "/api/v1/coupons"
        expect(response).to be_successful
        expect(response.status).to eq(200)

        response_data = parsed_response

        expect(response_data).to have_key(:data)
        expect(response_data[:data]).to be_an(Array)

        response_coupons = response_data[:data]

        expect(response_coupons.length).to eq(20)
      end
    end
  end
end
