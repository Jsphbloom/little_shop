require "rails_helper"

describe Merchant, type: :model do
  describe "relationships" do
    it { is_expected.to have_many :invoices }
    it { is_expected.to have_many :items }
  end

  describe "with_returned_items" do
    it "can return a list of merchants with returned items" do
      create_list(:merchant, 5)
      create(:invoice, status: "returned")

      expect(Merchant.with_returned_items.count).to eq(1)
    end
  end

  describe "with_item_count" do
    it "can add an item count to indexed merchants" do
      create(:merchant, id: 1)
      create(:merchant, id: 2)
      create(:merchant, id: 3)
      create(:item, merchant_id: 1)
      create(:item, merchant_id: 1)
      create(:item, merchant_id: 2)

      expect(Merchant.with_item_count[0].item_count).to eq(1)
      expect(Merchant.with_item_count[1].item_count).to eq(0)
      expect(Merchant.with_item_count[2].item_count).to eq(2)
    end
  end
end
