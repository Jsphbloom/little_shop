class Merchant < ApplicationRecord
  validates :name, presence: true
  has_many :invoices, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :customers, -> { distinct }, through: :invoices

  def self.sort_by_age
    Merchant.order(created_at: :desc)
  end

  def self.with_returned_items
    joins(:invoices)
      .where(invoices: { status: "returned" })
      .distinct
  end
end
