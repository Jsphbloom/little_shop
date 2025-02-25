require "rails_helper"

describe Merchant, type: :model do
  describe "relationships" do
    it { is_expected.to have_many :invoices }
    it { is_expected.to have_many :items }
  end
end
