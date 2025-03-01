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
  end
end
