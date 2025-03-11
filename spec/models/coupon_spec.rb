require "rails_helper"

describe Coupon, type: :model do
  describe "relationships" do
    it { is_expected.to have_one :invoice }
    it { is_expected.to belong_to :merchant }
  end

  describe "class methods" do
    describe "filter by active" do
      it "can return a list of coupons with the TRUE active status" do
        coup1 = create(:coupon, active: true)
        coup2 = create(:coupon, active: true)
        coup3 = create(:coupon, active: true)
        coup4 = create(:coupon, active: false)
        coup5 = create(:coupon, active: false)

        expect(Coupon.active_true.length).to eq(3)
        expect(Coupon.active_true).to eq([coup1, coup2, coup3])
      end
      it "can return a list of coupons with the FALSE active status" do
        coup1 = create(:coupon, active: true)
        coup2 = create(:coupon, active: true)
        coup3 = create(:coupon, active: true)
        coup4 = create(:coupon, active: false)
        coup5 = create(:coupon, active: false)

        expect(Coupon.active_false.length).to eq(2)
        expect(Coupon.active_false).to eq([coup4, coup5])
      end
    end

    describe "build coupon" do
      let!(:merchant) { create(:merchant) }
      let!(:invoice) { create(:invoice, merchant: merchant) }
      let(:coupon_params) do
        {
          name: Faker::Commerce.product_name,
          code: "TESTCODE123",
          discount_type: "percentage",
          discount_value: 25.0,
          merchant_id: merchant.id,
          invoice_id: invoice.id,
          active: true
        }
      end
      it "can create a coupon" do

        coupon = Coupon.build(coupon_params)

        expect(coupon).to be_a(Coupon)
        expect(coupon.name).to eq(coupon_params[:name])
        expect(coupon.discount_value).to eq(coupon_params[:discount_value])
        expect(coupon.invoice_id).to eq(invoice.id)
      end
      it 'updates the invoice with the coupon_id' do
      coupon = Coupon.build(coupon_params)

      invoice.reload
      expect(invoice.coupon_id).to eq(coupon.id)
      end

      it 'returns nil if no invoice is found' do
        coupon_params[:invoice_id] = 99999
        coupon = Coupon.build(coupon_params)

        expect(coupon).to be_nil
      end
    end
  end

  describe 'sad paths' do
    it 'returns an error when adding over 5 active coupons to one merchant' do
      merchant = create(:merchant)
      create_list(:coupon, 6, active: true, merchant: merchant)
      expect { create(:coupon, active: true, merchant: merchant) }.to raise_error(ActiveRecord::RecordInvalid)
      expect { create(:coupon, active: false, merchant: merchant) }.not_to raise_error
    end

    it 'returns an error when adding a duplicate coupon name' do
      merchant = create(:merchant)
      coup1 = create(:coupon, code: "TEST DEAL", merchant: merchant)
      expect { create(:coupon, code: "TEST DEAL", merchant: merchant) }.to raise_error(ActiveRecord::RecordInvalid)
      expect { create(:coupon, code: "TEST DEAL 2", merchant: merchant) }.not_to raise_error
    end
  end
end
