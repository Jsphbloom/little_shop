require "rails_helper"

describe Customer, type: :model do
  describe "relationships" do
    it { is_expected.to have_many :invoices }
  end
end
