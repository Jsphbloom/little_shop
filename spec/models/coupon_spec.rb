require "rails_helper"

describe Coupon, type: :model do
  describe "relationships" do
    it { is_expected.to have_many :invoices }
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
  end

  describe 'sad paths' do
    it 'returns an error when adding over 5 active coupons to one merchant' do
      merchant = create(:merchant)
      create_list(:coupon, 5, active: true, merchant: merchant)
      expect { create(:coupon, active: true, merchant: merchant) }.to raise_error(ActiveRecord::RecordInvalid)
      expect { create(:coupon, active: false, merchant: merchant) }.not_to raise_error
    end

    it 'returns an error when adding a duplicate coupon name' do
      merchant = create(:merchant)
      coup1 = create(:coupon, name: "TEST DEAL", merchant: merchant)
      expect { create(:coupon, name: "TEST DEAL", merchant: merchant) }.to raise_error(ActiveRecord::RecordInvalid)
      expect { create(:coupon, name: "TEST DEAL 2", merchant: merchant) }.not_to raise_error
    end
  end
end
