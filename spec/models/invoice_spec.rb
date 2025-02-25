require "rails_helper"

describe Invoice, type: :model do
  describe "relationships" do
    it { is_expected.to belong_to :customer }
    it { is_expected.to belong_to :merchant }
    it { is_expected.to have_many :transactions }
    it { is_expected.to have_many :invoice_items }
  end
end
