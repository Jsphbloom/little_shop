class Merchant < ApplicationRecord
  validates :name, presence: true
  has_many :invoices, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :customers, -> { distinct }, through: :invoices

  def self.sort_by_age
    order(created_at: :desc)
  end

  def self.with_returned_items
    joins(:invoices)
      .where(invoices: {status: "returned"})
      .distinct
  end

  def self.search(fragment)
    find_by("name ILIKE ?", "%#{fragment}%")
  end

  def self.search_all(fragment)
    where("name ILIKE ?", "%#{fragment}%")
  end

  def self.with_item_count
    joins(:items)
      .select("merchants.id, merchants.name, COUNT(items.id) AS item_count")
      .group("merchants.id, merchants.name")
      .order("merchants.id")
  end
end
