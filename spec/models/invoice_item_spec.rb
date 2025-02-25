require "rails_helper"

describe InvoiceItem, type: :model do
  describe "relationships" do
    it { is_expected.to belong_to :invoice }
    it { is_expected.to belong_to :item }
  end
end
