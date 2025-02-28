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

  def self.find_by_name_fragment(fragment)
    Merchant.where('name ILIKE ?',"%#{fragment}%").first
  end
  
  def self.with_item_count
    left_joins(:items)
    .select("merchants.id, merchants.name, COUNT(items.id) AS item_count")
    .group("merchants.id, merchants.name")
  end
end
