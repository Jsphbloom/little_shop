class Merchant < ApplicationRecord
  validates :name, presence: true
  has_many :invoices, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :customers, -> { distinct }, through: :invoices

def self.sort_by(direction)
  Merchant.order(created_at: direction.to_sym)
end

  def self.with_returned_items
    joins(:invoices)
      .where(invoices: { status: "returned" })
      .distinct
  end
end
