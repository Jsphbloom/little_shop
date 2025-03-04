require "rails_helper"

describe Item, type: :model do
  describe "relationships" do
    it { is_expected.to have_many :invoice_items }
    it { is_expected.to belong_to :merchant }
  end

  describe "class methods" do
    describe ".sorted_by_price" do
      it "can return a list of items sorted by price" do
        create(:item, unit_price: 10)
        create(:item, unit_price: 2)
        create(:item, unit_price: 7)
        create(:item, unit_price: 4)
        create(:item, unit_price: 100)

        sorted_prices = Item.sort_by_price.pluck(:unit_price)

        expect(sorted_prices).to eq([2, 4, 7, 10, 100])
      end
    end

    describe ".search" do
      it "can find item by name" do
        item = create(:item, name: "Something")
        create(:item, name: "Nothing")

        params = {name: "some"}

        expect(Item.search(params)).to eq(item)
      end

      it "can find item by min_price" do
        item = create(:item, unit_price: 15.0)
        create(:item, unit_price: 9.0)

        params = {min_price: 10}

        expect(Item.search(params)).to eq(item)
      end

      it "can find item by max_price" do
        item = create(:item, unit_price: 9.0)
        create(:item, unit_price: 15.0)

        params = {max_price: 10}

        expect(Item.search(params)).to eq(item)
      end

      it "can find item by min_price and max_price" do
        item = create(:item, unit_price: 9.0)
        create(:item, unit_price: 15.0)
        create(:item, unit_price: 4.0)

        params = {min_price: 5, max_price: 10}

        expect(Item.search(params)).to eq(item)
      end
    end

    describe ".search_all" do
      it "can find item by name" do
        items = create_list(:item, 25, name: "Something")
        create_list(:item, 20, name: "Nothing")

        params = {name: "some"}

        expect(Item.search_all(params)).to eq(items)
      end

      it "can find item by min_price" do
        items = create_list(:item, 25, unit_price: 15.0)
        create_list(:item, 20, unit_price: 9.0)

        params = {min_price: 10}

        expect(Item.search_all(params)).to eq(items)
      end

      it "can find item by max_price" do
        items = create_list(:item, 25, unit_price: 9.0)
        create_list(:item, 20, unit_price: 15.0)

        params = {max_price: 10}

        expect(Item.search_all(params)).to eq(items)
      end

      it "can find item by min_price and max_price" do
        items = create_list(:item, 25, unit_price: 9.0)
        create_list(:item, 20, unit_price: 15.0)
        create_list(:item, 30, unit_price: 4.0)

        params = {min_price: 5, max_price: 10}

        expect(Item.search_all(params)).to eq(items)
      end
    end

    describe ".find_by_merchant" do
      it "returns all items belonging to a merchant" do
        merchant = create(:merchant)
        items = create_list(:item, 25, merchant: merchant)
        create_list(:item, 30)

        expect(Item.find_by_merchant(merchant.id)).to eq(items)
      end
    end
  end
end
