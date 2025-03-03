require "rails_helper"

describe Merchant, type: :model do
  describe "relationships" do
    it { is_expected.to have_many :invoices }
    it { is_expected.to have_many :items }
  end

  describe "class methods" do
    describe ".sort_by_age" do
      it "can return a list of merchants sorted by creation time" do
        first = create(:merchant)
        second = create(:merchant)
        third = create(:merchant)
        fourth = create(:merchant)
        fifth = create(:merchant)

        expect(Merchant.sort_by_age).to eq([fifth, fourth, third, second, first])
      end
    end

    describe ".with_returned_items" do
      it "can return a list of merchants with returned items" do
        create_list(:merchant, 5)
        create(:invoice, status: "returned")

        expect(Merchant.with_returned_items.count).to eq(1)
      end
    end

    describe ".search" do
      it "finds a single merchant by a name fragment" do
        merchant1 = create(:merchant, name: "Logan's Store")
        merchant2 = create(:merchant, name: "Alec's Store")
        create(:merchant, name: "Logan's Shop")
        create(:merchant, name: "Alec's Shop")
        create(:merchant)

        expect(Merchant.search("Logan")).to eq(merchant1)
        expect(Merchant.search("Alec")).to eq(merchant2)
      end
    end

    describe ".search_all" do
      it "finds a single merchant by a name fragment" do
        merchants1 = create_list(:merchant, 25, name: "Logan's Store")
        merchants2 = create_list(:merchant, 20, name: "Alec's Store")
        create_list(:merchant, 30)

        expect(Merchant.search_all("Logan")).to eq(merchants1)
        expect(Merchant.search_all("Alec")).to eq(merchants2)
      end
    end

    describe ".with_item_count" do
      it "can add an item count to indexed merchants" do
        create_list(:item, 30, merchant: create(:merchant))

        expect(Merchant.with_item_count[0].item_count).to eq(30)
      end
    end
  end
end
