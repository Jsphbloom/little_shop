class Merchant < ApplicationRecord
  validates :name, presence: true
  has_many :invoices, dependent: :destroy
  has_many :items, dependent: :destroy

  def self.with_returned_items
    joins(:invoices)
      .where(invoices: { status: "returned" })
      .distinct
  end
end
