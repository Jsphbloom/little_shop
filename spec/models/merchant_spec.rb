require "rails_helper"

describe Merchant, type: :model do
  describe "relationships" do
    it { is_expected.to have_many :invoices }
    it { is_expected.to have_many :items }
  end

  describe ".find_by_name_fragment" do
    it "finds a single merchant by a name fragment" do 
      merchant1 = Merchant.create!(name: "Logan's Store")
      merchant2 = Merchant.create!(name: "Alec's Store")
      merchant3 = Merchant.create!(name: "Logan's Shop")
      merchant4 = Merchant.create!(name: "Alec's Shop")
      merchant5 = Merchant.create!(name: "Dummy Merchant 1")

      expect(Merchant.find_by_name_fragment("Logan")).to eq(merchant1)
      expect(Merchant.find_by_name_fragment("Alec")).to eq(merchant2)
    end
  end
end
