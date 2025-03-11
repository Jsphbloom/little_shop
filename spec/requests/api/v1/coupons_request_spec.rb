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

        response_coupons.each do |coupon|
          expect(coupon).to have_key(:id)
          expect(coupon[:id]).to be_a(String)

          expect(coupon).to have_key(:type)

          expect(coupon[:type]).to eq("coupon")

          expect(coupon).to have_key(:attributes)
          expect(coupon[:attributes]).to be_a(Hash)
        end
      end
    end

    describe "GET /api/v1/coupons/:id" do
      it "can return a single coupon" do
        merchants = create_list(:merchant, 5)

        merchants.each do |merchant|
          create(:coupon, merchant: merchant)
        end

        coupon = Coupon.first

        get "/api/v1/coupons/#{coupon.id}"
        expect(response).to be_successful
        expect(response.status).to eq(200)

        response_data = parsed_response

        expect(response_data).to have_key(:data)

        response_coupons = response_data[:data]

        # binding.pry
        expect(response_data.length).to eq(1)
        expect(response_coupons.length).to eq(3)
        expect(response_coupons).to have_key(:id)
        expect(response_coupons).to have_key(:type)
        expect(response_coupons).to have_key(:attributes)
        expect(response_coupons[:id]).to be_a(String)


        expect(response_coupons[:type]).to eq("coupon")

        expect(response_coupons[:attributes]).to be_a(Hash)
      end
    end

    describe "POST /api/v1/coupons" do
      it "can create a coupon" do
        merchant = create(:merchant)
        invoice = create(:invoice, merchant: merchant)
        coupon_params = {name: Faker::Commerce.vendor, code: "BOGO50", discount_type: "dollar", discount_value: 50.0, merchant_id: merchant.id, invoice_id: invoice.id, active: true}
        headers = {"CONTENT_TYPE" => "application/json"}

        post "/api/v1/coupons", headers: headers, params: JSON.generate(coupon: coupon_params)

        expect(response).to be_successful
        expect(response.status).to eq(201)

        created_coupon = Coupon.last

        expect(created_coupon).to have_attributes(coupon_params)

        response_data = parsed_response

        expect(response_data[:data]).to include(
          id: created_coupon.id.to_s,
          type: "coupon"
        )

        expect(response_data[:data]).to have_key(:attributes)
        expect(response_data[:data][:attributes]).to be_a(Hash)
        expect(response_data[:data][:attributes]).to include(coupon_params)
      end
    end

    describe "PATCH /api/v1/coupons/:id" do
      it "can update an existing coupon" do
        merchant = create(:merchant)
        coupon = create(:coupon, merchant: merchant, active: true)

        patch "/api/v1/coupons/#{coupon.id}"

        expect(response).to be_successful
        expect(response.status).to eq(200)

        coupon = Coupon.find(coupon.id)

        response_data = parsed_response

        expect(response_data[:data]).to include(
          id: coupon.id.to_s,
          type: "coupon"
        )

        expect(response_data[:data]).to have_key(:attributes)
        expect(response_data[:data][:attributes]).to be_a(Hash)
        expect(response_data[:data][:attributes][:active]).to eq(false)
      end
    end
  end

   describe "sad paths" do
      it "will gracefully handle get with a nonexistent coupon id" do
        get "/api/v1/coupons/0"

        expect(response).not_to be_successful
        expect(response.status).to eq(404)

        response_data = parsed_response

        expect(response_data[:errors]).to eq(["404"])
        expect(response_data[:message]).to eq("Couldn't find Coupon with 'id'=0")
      end
    end
end
