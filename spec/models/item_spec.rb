require "rails_helper"

describe Item, type: :model do
  describe "relationships" do
    it { is_expected.to have_many :invoice_items }
    it { is_expected.to belong_to :merchant }
  end
end
