require "rails_helper"

describe Invoice, type: :model do
  describe "relationships" do
    it { is_expected.to belong_to :customer }
    it { is_expected.to belong_to :merchant }
    it { is_expected.to have_many :transactions }
    it { is_expected.to have_many :invoice_items }
  end

  describe "class methods" do
    describe ".filter_by_status" do
      it "returns only invoices with matching status" do
        invoices = create_list(:invoice, 100, status: "returned")
        create_list(:invoice, 30, status: "packaged")
        create_list(:invoice, 20, status: "shipped")

        expect(Invoice.filter_by_status("returned").to_a).to match_array(invoices)
      end
    end
  end
end
