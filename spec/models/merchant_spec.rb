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
end
